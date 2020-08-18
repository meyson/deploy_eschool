import argparse
import os
import time
from pathlib import Path
from string import Template

import paramiko
import requests
import yaml

# global variables
SSH_USER = os.environ['USER']
# directory that contains this script and credentials
DIR = Path('/home', SSH_USER, 'deploy_eschool')

API_KEY = Path(DIR, '.circlecitoken').read_text().strip()

# Interval between deployments
sleep_betwen_deploy = 10

# handle command line arguments
parser = argparse.ArgumentParser(description='Deploy eschool')
parser.add_argument('-j', '--job', default='', type=int, help='job number')
parser.add_argument('-p', '--project', default='be', type=str, help='project be or fe')
args = parser.parse_args()


def read_yaml(path):
    with open(path, 'r') as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)


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


# dictionary to bash variables
def generate_bash_vars(pairs):
    return ''.join([f'export {key}={value} \n' for key, value in pairs.items()])


be_temp = f'''
# generated variables
$bash_vars

pid=$$(<"/var/run/user/1000/eschool.pid")
kill $$pid
rm -f "$app_path"
curl -L $url > $app_path
# run app
java -jar "$app_path" &
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


def deploy_artifacts(server, artifacts, script, mapping=None):
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
        if mapping is not None:
            script = script.substitute(name=name, url=url, **mapping)
        else:
            script = script.substitute(name=name, url=url)

        # FIXME DELETE
        print(script)
        channel.exec_command(script)
        time.sleep(sleep_betwen_deploy)
        print(f'Deploying {url} to {server}', '*' * 20)


def deploy_be(conf, db):
    # merge two dictionaries
    mysql = {**conf['database']['mysql'], **db['mysql']}
    slug = 'github/meyson/eSchool'
    be_servers = conf['be_servers']

    db_url = f'jdbc:mysql://{mysql["ip"]}:{mysql["port"]}/{mysql["db"]}?useUnicode=true' \
             '&characterEncoding=utf8&createDatabaseIfNotExist=true&&autoReconnect=true&useSSL=false'
    bash_vars = generate_bash_vars({
        'DATASOURCE_USERNAME': mysql['user'],
        'DATASOURCE_PASSWORD': mysql['password'],
        'DATASOURCE_URL': db_url
    })
    temp_vars = {
        'bash_vars': bash_vars,
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
    config = read_yaml(DIR / 'config.yaml')
    db_creds = read_yaml(DIR / 'db_credentials_eschool.yaml')

    if args.project == 'be':
        deploy_be(config, db_creds)
    elif args.project == 'fe':
        deploy_fe(config)


if __name__ == '__main__':
    main()
