# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Glocal variables
CFG = YAML.load_file('config.yaml')

gcp = CFG['gcp']
ssh = CFG['ssh']
be_servers = CFG['be_servers']
fe_servers = CFG['fe_servers']

project_id = gcp['project_id']
project_key = gcp['project_key']
ssh_user = ssh['user']
ssh_key = ssh['key']

# be servers
be_ips = be_servers['ips']

be_port = be_servers['port']
lb_be = CFG['lb_be']

# fe servers
fe_ips = fe_servers['ips']

# databases
conf_mysql = CFG['database']['mysql']
db_credentials_file = CFG['database']['credentials']
db_credentials = YAML.load_file(db_credentials_file)
creds_mysql = db_credentials['mysql']

# circleci
circleci_tocken = CFG['other']['circleci_tocken']


Vagrant.configure("2") do |config|
  config.vm.box = "google/gce"
  config.vm.define "db" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = project_id
      google.google_json_key_location = project_key

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-db"
        zone_config.machine_type = "g1-small"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-8"
        zone_config.network_ip = conf_mysql['ip']
      end

      override.ssh.username = ssh_user
      override.ssh.private_key_path = ssh_key
      override.vm.provision :shell, path: "vagrant_provision/db.sh",
      args: be_ips,
      env: {
          "DB_USER_NAME" => creds_mysql['user'],
          "DB_USER_PWD" => creds_mysql['password'],
      }
    end
  end

  # todo iterate over numbers
  (0..be_ips.length - 1).each do |i|
    server_ip = be_ips[i]
    config.vm.define "be#{i}" do |subconfig|
      subconfig.vm.provider :google do |google, override|
        google.google_project_id = project_id
        google.google_json_key_location = project_key

        google.zone = "europe-west3-c"
        google.zone_config "europe-west3-c" do |zone_config|
          zone_config.name = "eschool-be#{i}"
          zone_config.machine_type = "g1-small"
          zone_config.disk_size = "20"
          zone_config.image_family = "centos-7"
          zone_config.network_ip = server_ip
        end

        override.ssh.username = ssh_user
        override.ssh.private_key_path = ssh_key 
        override.vm.provision :shell, path: "vagrant_provision/be.sh",
        env: {"DIST_DIR" => be_servers['dir']}
      end
    end
  end

  config.vm.define "lb_be" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = project_id
      google.google_json_key_location = project_key
      google.tags = ['http-server']

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-lb-be"
        zone_config.machine_type = "f1-micro"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-7"
        zone_config.network_ip = lb_be['ip']
        zone_config.external_ip = lb_be['external_ip']
      end

      override.ssh.username = ssh_user
      override.ssh.private_key_path = ssh_key
      override.vm.provision "configure_bastion",
        type: "shell",
        preserve_order: true,
        path: "vagrant_provision/bastion.sh",
        env: { "REGULAR_USER" => ssh_user }
      override.vm.provision "lb",
        type: "shell",
        preserve_order: true,
        path: "vagrant_provision/lb.sh",
        args: be_ips,
        env: { "PORT" => be_port }
      override.trigger.after :up do |trigger|
        host = lb_be['external_ip']
        trigger.info = "Transferring ssh keys..."
        trigger.run = {
          path: "vagrant_provision/bastion_ssh.sh",
          args: [ssh_user, host, ssh_key, db_credentials_file, circleci_tocken]
        }
      end
    end
  end

#  config.vm.define "lb_fe" do |subconfig|
#    subconfig.vm.provider :google do |google, override|
#      google.google_project_id = project_id
#      google.google_json_key_location = project_key
#      google.tags = ['http-server']
#
#      google.zone = "europe-west3-c"
#      google.zone_config "europe-west3-c" do |zone_config|
#        zone_config.name = "eschool-lb-fe"
#        zone_config.machine_type = "f1-micro"
#        zone_config.disk_size = "20"
#        zone_config.image_family = "centos-7"
#        zone_config.network_ip = ENV["FE_LB_IP"]
#      end
#
#      override.ssh.username = ssh_user
#      override.ssh.private_key_path = ssh_key
#      override.vm.provision "shell", path: "vagrant_provision/lb.sh",
#      env: {
#          "SERVER_1" => ENV["FE_SERVER_1"],
#          "SERVER_2" => ENV["FE_SERVER_2"],
#          "PORT"     => "80"
#      }
#    end
#  end
#
#  config.vm.define "fe1" do |subconfig|
#    subconfig.vm.provider :google do |google, override|
#        google.google_project_id = project_id
#        google.google_json_key_location = project_key
#        google.tags = ['http-server']
#
#        google.zone = "europe-west3-c"
#        google.zone_config "europe-west3-c" do |zone_config|
#          zone_config.name = "eschool-fe1"
#          zone_config.machine_type = "f1-micro"
#          zone_config.disk_size = "20"
#          zone_config.image_family = "centos-7"
#          zone_config.network_ip = ENV["FE_SERVER_1"]
#        end
#
#        override.ssh.username = ssh_user
#        override.ssh.private_key_path = ssh_key
#        override.vm.provision "shell", path: "vagrant_provision/fe.sh",
#        env: {
#          "SSH_USER" => ssh_user
#        }
#    end
#  end
end
