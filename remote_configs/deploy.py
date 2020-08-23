import argparse
import os
import time
from pathlib import Path
from string import Template

import paramiko
import requests
import yaml


def read_yaml(path):
    with open(path, 'r') as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)


# handle command line arguments
parser = argparse.ArgumentParser(description='Deploy eschool')
parser.add_argument('-j', '--job', default='', type=int, help='job number')
parser.add_argument('-p', '--project', default='be', type=str, help='project be or fe')
parser.add_argument('-c', '--config', default='config.yaml', type=str, help='project config file')
parser.add_argument('-s', '--credentials', default='credentials.yaml', type=str, help='project credentials file')
args = parser.parse_args()

# directory that contains this script and credentials
DIR = Path('/home', os.environ['USER'], 'deploy_eschool')
# Interval between deployments
sleep_betwen_deploy = 10
# read yaml configs
CONFIG = read_yaml(DIR / args.config)
CREDS = read_yaml(DIR / args.credentials)

API_KEY = CREDS['circleci_tocken']
SSH_USER = CREDS['ssh']['user']


# Fetch artifact using CircliCI REST API
def get_artifact(slug, job_number):
    headers = {
        'Accept': 'application/json',
        'Circle-Token': f'{API_KEY}'
    }
    response = requests.get(
        f'https://circleci.com/api/v2/project/{slug}/{job_number}/artifacts',
        headers=headers)
    json = response.json()
    if 'items' not in json or not json['items']:
        print('response', json)
        raise Exception("This job doesn't contain artifacts")
    return json['items']


def deploy_artifacts(server, artifacts, script, script_mapping=None):
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=server,
                   username=SSH_USER,
                   timeout=4)
    transport = client.get_transport()
    channel = transport.open_session()

    for artifact in artifacts:
        url = artifact['url']
        name = artifact['path'].split('/')[-1]
        mapping = {
            'name': name,
            'url': url
        }
        if script_mapping is not None:
            mapping = {**mapping, **script_mapping}

        script = script.substitute(mapping)
        channel.exec_command(script)
        time.sleep(sleep_betwen_deploy)
        print(f'Deploying {url} to {server}', '*' * 20)


# dictionary to spring application properties
def generate_app_props(pairs):
    return ''.join([f'-D{key}="{value}" ' for key, value in pairs.items()])


be_temp = f'''
pid=$$(<"/var/run/user/1000/eschool.pid")
kill $$pid
rm -f "$app_path"
curl -L $url > $app_path
java $app_props -jar "$app_path" &
pid=$$!
echo $$pid > "/var/run/user/1000/eschool.pid" 
'''

fe_temp = f'''
sudo rm -rf /var/www/eschool/
sudo mkdir -p /var/www/eschool/
sudo chown -R "$user:$user" /var/www/eschool/
sudo chcon -R -t httpd_sys_content_t /var/www/eschool/
curl -Ls $url | tar xvz -C /var/www/eschool/
sudo \\cp /vagrant/remote_configs/fe/.htaccess /var/www/eschool/
'''

templates = {
    'be': Template(be_temp),
    'fe': Template(fe_temp)
}


def deploy_be(conf, db):
    # merge two dictionaries
    mysql = {**conf['database']['mysql'], **db['mysql']}
    slug = 'github/meyson/eSchool'
    be_servers = conf['be_servers']

    db_url = f'jdbc:mysql://{mysql["ip"]}:{mysql["port"]}/{mysql["db"]}?useUnicode=true' \
             '&characterEncoding=utf8&createDatabaseIfNotExist=true&&autoReconnect=true&useSSL=false'
    app_props = generate_app_props({
        'spring.datasource.username': mysql['user'],
        'spring.datasource.password': mysql['password'],
        'spring.datasource.url': db_url
    })
    temp_vars = {
        'app_props': app_props,
        'app_path': be_servers['dir'] + '/' + be_servers['app']
    }

    artifacts = get_artifact(slug=slug, job_number=args.job)
    for server in be_servers['ips']:
        try:
            deploy_artifacts(server, artifacts, templates['be'], temp_vars)
        except Exception as e:
            print(e)
            print(server, 'error')


def deploy_fe(conf):
    slug = 'github/meyson/final_project'
    artifacts = get_artifact(slug=slug, job_number=args.job)
    fe_servers = conf['fe_servers']

    for server in fe_servers['ips']:
        try:
            deploy_artifacts(server, artifacts, templates['fe'], {
                'user': SSH_USER
            })
        except Exception as e:
            print(e)
            print(server, 'error')


def main():
    if args.project == 'be':
        # we only need credentials when we deploy back-end servers
        deploy_be(CONFIG, CREDS)
    elif args.project == 'fe':
        deploy_fe(CONFIG)


if __name__ == '__main__':
    main()
