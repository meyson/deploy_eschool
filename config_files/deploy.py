import argparse
import requests
from pathlib import Path
import shutil
import paramiko
import os

SSH_USER = os.environ['USER']
API_KEY = Path(f'/home/{SSH_USER}/.circlecitoken').read_text()[:-1]

parser = argparse.ArgumentParser(description='Deploy eschool')
parser.add_argument('-j', "--job", default='', type=str, help='job number')

args = parser.parse_args()


def download_file(url):
    local_filename = url.split('/')[-1]
    with requests.get(url, stream=True) as r:
        with open(local_filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

    return local_filename


def get_artifact(project_slug, job_number="latest"):
    headers = {
        'Accept': 'application/json',
        'Circle-Token': f'{API_KEY}'
    }

    r = requests.get(
        f'https://circleci.com/api/v2/project/{project_slug}/{job_number}/artifacts',
        params={}, headers=headers)

    return r.json()


def deploy_artifacts(server, artifacts):
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(server, username=SSH_USER)

    for artifact in artifacts:
        url = artifact['url']
        print(f'Deploying {url} to {server}')
        command = f'wget {url} -P /home/{SSH_USER}/'
        stdin, stdout, stderr = client.exec_command(command)
        for line in stdout:
            print('... ' + line.strip('\n'))
        client.close()
        print('*' * 60)


def main():
    servers = ['10.156.0.50', '10.156.0.51']
    artifacts = get_artifact('github/meyson/eSchool', job_number=args.job)['items']
    print(artifacts)
    for server in servers:
        try:
            deploy_artifacts(server, artifacts)
        except Exception as e:
            print(e)
            print(server, 'error')


if __name__ == '__main__':
    main()
