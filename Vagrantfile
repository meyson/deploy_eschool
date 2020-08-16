# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

# Read YAML file with box details
CFG = YAML.load_file('details.yaml')

project_id = CFG['gcp']['project_id']
project_key = CFG['gcp']['project_key']
ssh_user = CFG['ssh']['user']
ssh_key = CFG['ssh']['key']

lb_be = CFG['lb_be']
be_ips = CFG['be_servers']['ips']
be_port = CFG['be_servers']['port']

fe_ips = CFG['fe_servers']['ips']

db_credentials_file = CFG['database']['credentials']
db_credentials = YAML.load_file(db_credentials_file)
mysql = db_credentials['mysql']

# todo DELETE show details
puts CFG.inspect
puts db_credentials.inspect

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
        zone_config.network_ip = CFG["database"]['ip']
      end

      # TODO
      override.vm.provision :shell, path: "vagrant_provision/db.sh",
      env: {
          "DATABASE" => mysql['database'],
          "DB_USER_NAME" => mysql['user'],
          "DB_USER_PWD" => mysql['password'],
          "DB_SERVER_IP" => CFG['database']['ip'],
          "BE_SERVER_1" => be_ips[0],
          "BE_SERVER_2" => be_ips[1],
      }
      override.ssh.username = ssh_user
      override.ssh.private_key_path = ssh_key
    end
  end

  be_ips.each do |server_ip|
    config.vm.define "be1" do |subconfig|
      subconfig.vm.provider :google do |google, override|
        google.google_project_id = project_id
        google.google_json_key_location = project_key

        google.zone = "europe-west3-c"
        google.zone_config "europe-west3-c" do |zone_config|
          zone_config.name = "eschool-be1"
          zone_config.machine_type = "g1-small"
          zone_config.disk_size = "20"
          zone_config.image_family = "centos-7"
          zone_config.network_ip = server_ip
        end

        override.ssh.username = ssh_user
        override.ssh.private_key_path = ssh_key 
        override.vm.provision :shell, path: "vagrant_provision/be.sh"
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
        path: "vagrant_provision/bastion.sh"
      override.vm.provision "lb",
        type: "shell",
        preserve_order: true,
        path: "vagrant_provision/lb.sh",
        env: {
            "SERVER_1" => be_ips[0],
            "SERVER_2" => be_ips[1],
            "PORT"     => be_port,
        }
      override.trigger.after :up do |trigger|
        server = "#{ssh_user}@#{lb_be['external_ip']}"
        trigger.info = "Transferring ssh keys..."
        trigger.run = {path: "vagrant_provision/bastion_trigger.sh", args: [server]}
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
