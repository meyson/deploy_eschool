import argparse
import os
import shutil
from pathlib import Path

import paramiko
import requests
import yaml

# global variables
SSH_USER = os.environ['USER']
# directory that contains this script and credentials
DIR = Path('/home', SSH_USER, 'deploy_eschool')

API_KEY = Path(DIR, '.circlecitoken').read_text().strip()
PROJECT_SLUG = 'github/meyson/eSchool'

# handle command line arguments
parser = argparse.ArgumentParser(description='Deploy eschool')
parser.add_argument('-j', '--job', default='', type=int, help='job number')
args = parser.parse_args()


def read_yaml(path):
    with open(path, 'r') as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)


def download_file(url):
    local_filename = url.split('/')[-1]
    with requests.get(url, stream=True) as r:
        with open(local_filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

    return local_filename


def get_artifact(job_number="latest"):
    headers = {
        'Accept': 'application/json',
        'Circle-Token': f'{API_KEY}'
    }
    response = requests.get(
        f'https://circleci.com/api/v2/project/{PROJECT_SLUG}/{job_number}/artifacts',
        headers=headers)
    json = response.json()
    if 'items' not in json or not json['items']:
        print('response', json)
        raise Exception("This job doesn't contain artifacts")
    return json['items']


def deploy_artifacts(server, artifacts):
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=server,
                   username=SSH_USER,
                   timeout=4)

    for artifact in artifacts:
        url = artifact['url']
        print(f'Deploying {url} to {server}')
        # send artifact url to server
        command = f'sudo bash -c "echo "{url}" > /opt/eschool/eschool_url.txt"'
        stdin, stdout, stderr = client.exec_command(command)
        for line in stderr:
            print('... ' + line.strip('\n'))
        for line in stdout:
            print('... ' + line.strip('\n'))
        client.close()
        print('*' * 60)


def main():
    config = read_yaml(DIR / 'config.yaml')
    db_creds = read_yaml(DIR / 'db_credentials_eschool.yaml')
    mysql = db_creds['mysql']

    servers = config['be_servers']
    artifacts = get_artifact(job_number=args.job)
    print(artifacts)
    for server in servers['ips']:
        try:
            deploy_artifacts(server, artifacts)
        except Exception as e:
            print(e)
            print(server, 'error')


if __name__ == '__main__':
    main()
