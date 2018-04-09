import json
import python_terraform as pt
import re
import yaml
from git import Repo
import subprocess
import time
import logging
import os
import argparse
from argparse import RawTextHelpFormatter
import shutil
import json
import jinja2, glob


LOGFILE = "infra-log-%s.log" %(str(time.time()))
CONSOLE_LOGGER = None
FILE_LOGGER = None

def init_logging():
    global LOGFILE
    global CONSOLE_LOGGER
    global FILE_LOGGER
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    logging.basicConfig(filename=LOGFILE,
                        level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    log_formatter = logging.Formatter(fmt='%(asctime)s %(levelname)-8s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    FILE_LOGGER = logging.getLogger('filelogger')
    FILE_LOGGER.setLevel(logging.getLevelName('DEBUG'))
    CONSOLE_LOGGER = logging.getLogger('consolelogger')
    CONSOLE_LOGGER.addHandler(logging.StreamHandler())
    CONSOLE_LOGGER.handlers[0].setFormatter(log_formatter)
    CONSOLE_LOGGER.setLevel(logging.getLevelName('DEBUG'))


init_logging()
def run_command(command):
    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE,  shell=True)
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                CONSOLE_LOGGER.debug(output.strip())
        rc = process.poll()
        return rc
    except Exception as e:
        CONSOLE_LOGGER.error(str(e))


def clone_git_repo(repo_url, branch):
    path = os.getcwd()
    pnda_path = os.path.join(path,'pnda-cli')
    if os.path.exists(pnda_path):
        shutil.rmtree(pnda_path, ignore_errors=True)
    p = Repo.clone_from(repo_url, pnda_path)
    os.chdir('pnda-cli')
    run_command("git checkout {0}" .format(branch))
    return path, pnda_path
     
def create_production_json_file(flavor='pico'):
    data = yaml.load(open("output.yaml"))
    output_dict = {}
    output_file = "%s.json" %flavor
    for key in data:
        node_name = key.split("_")[0]
        value = data[key]
        node_type = node_name
        if node_name == "public":
            continue
        if "mgr-1" in node_name and flavor == "pico":
            node_type = "hadoop-mgr"
        if isinstance(value, (str, unicode)):
            output_dict[node_name] = {}
            if node_name == "hadoop-edge":
                output_dict[node_name].update({"is_saltmaster":True,"is_console":True})
            if node_name == "bastion":
                output_dict[node_name].update({"is_bastion":True,"public_ip_address":data["public_ip"]})
            output_dict[node_name]["ip_address"]=value
            output_dict[node_name]["node_type"]= node_type
        else: 
            for i in range(0,len(value)):
                output_dict[node_name+"-"+str(i)] = {}
                output_dict[node_name+"-"+str(i)]["ip_address"]=value[i]
                output_dict[node_name+"-"+str(i)]["node_type"]= node_type
    with open(output_file,"w") as json_data:
        json.dump(output_dict,json_data,sort_keys=True, indent=4)
    return output_file

def copy_key_and_json_file(key_name, flavor):
    json_file = '%s.json' % flavor
    shutil.copy(json_file, './pnda-cli/existing-machines/')
    file_path = os.path.join('./pnda-cli/existing-machines',json_file)
    key_file = '%s.pem' % key_name
    shutil.copy(key_file, './pnda-cli')
#    os.chdir('pnda-cli/')
    key_file = os.path.join('./pnda-cli',key_file)
    os.chmod(key_file, 0400)
    return os.path.abspath(file_path)
    
def create_env_file(input_data):
    template_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath='./')) 
    template = template_env.get_template("pnda_env.j2")
    output = template.render(input_data)
    with open('./pnda-cli/pnda_env.yaml', 'w') as outfile:
        outfile.write(output)
    return None
    
    
def update_pnda_yaml(mirror_ip, access_key, secret_key, region, branch, os_user):
    config_data = json.load(open("input.json"))
    config_data.update({"mirror_ip": mirror_ip, "access_key": access_key, "secret_key": secret_key, "region":region, "branch": branch, "os_user":os_user})
    create_env_file(config_data)
    return None

def get_args():
    epilog = """examples:
  - creates pico pnda cluster
    """

    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter,
                                     description='Creates PNDA pico cluster',
                                     epilog=epilog)
    parser.add_argument('command', help='Mode of operation',
                        choices=['create'])
    parser.add_argument('-i', '--mirror-ip',
                             help='Mirror server ip', required=True)
    parser.add_argument('-b','--branch', help='Branch of pnda-cli to checkout', required=True)
    parser.add_argument('-a', '--access-key', help='pnda variables to deploy PNDA', required=True)
    parser.add_argument('-r', '--region', help='pnda variables to deploy PNDA', required=True)
    parser.add_argument('-k', '--secret-key', help='pnda variables to deploy PNDA', required=True)
    parser.add_argument('-s', '--keypair', help='keypair name for \
                             ssh to mirror server', required=True)
    parser.add_argument('-u', '--user', help='Username to ssh into instances', required=True)
    parser.add_argument('-f', '--flavor', help='flavor of PNDA', required=True)
    args = parser.parse_args()
    return args

def deploy_pnda(args, pnda_path, json_path):
    try:
        FILE_LOGGER.info("Installing required python packages for PNDA")
        run_command("pip install -r requirements.txt")
        path = os.path.join(pnda_path, 'cli')
        os.chdir(path)
        command = 'python pnda-cli.py create -e pnda-ubuntu -s {} -m {} -f pico ' .format(args.keypair, json_path)
        FILE_LOGGER.info(command)
        run_command(command)
    except Exception as e:
        FILE_LOGGER(str(e))

def main():
    args = get_args()
    json_file_name = create_production_json_file()
    current_path, pnda_path = clone_git_repo("https://github.com/pndaproject/pnda-cli.git", args.branch)
    os.chdir(current_path)
    json_path = copy_key_and_json_file(args.keypair, args.flavor)
    update_pnda_yaml(args.mirror_ip, args.access_key, args.secret_key, args.region, args.branch, args.user)
    deploy_pnda(args, pnda_path, json_path)

if __name__ == "__main__":
    try:
        main()
    except Exception as exception:
        FILE_LOGGER.error(exception)
        raise
