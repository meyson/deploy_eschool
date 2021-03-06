# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# load config file
CFG = YAML.load_file('config.yaml')
# load credentials file
CREDS = YAML.load_file(CFG['credentials'])

gcp = CFG['gcp']
ssh = CREDS['ssh']

# google cloud settings
project_id = gcp['project_id']
project_key = gcp['project_key']
zone = gcp['zone']

# ssh keys
ssh_user = ssh['user']
ssh_key = ssh['key']

# be servers
be_servers = CFG['be_servers']
be_ips = be_servers['ips']
be_port = be_servers['port']

# fe servers
fe_servers = CFG['fe_servers']
fe_ips = fe_servers['ips']

# load balancers
lb_fe = CFG['lb_fe']
lb_be = CFG['lb_be']

# databases
conf_mysql = CFG['database']['mysql']
creds_mysql = CREDS['mysql']


Vagrant.configure("2") do |config|
  config.vm.box = "google/gce"

  # Database
  config.vm.define "db" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = project_id
      google.google_json_key_location = project_key
      google.tags = ['db']

      google.zone = zone
      google.zone_config zone do |zone_config|
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

  # Back-end servers
  (0..be_ips.length - 1).each do |i|
    server_ip = be_ips[i]
    config.vm.define "be#{i}" do |subconfig|
      subconfig.vm.provider :google do |google, override|
        google.google_project_id = project_id
        google.google_json_key_location = project_key
        google.tags = ['be', 'http-server']

        google.zone = zone
        google.zone_config zone do |zone_config|
          zone_config.name = "eschool-be#{i}"
          zone_config.machine_type = "g1-small"
          zone_config.disk_size = "20"
          zone_config.image_family = "centos-8"
          zone_config.network_ip = server_ip
        end

        override.ssh.username = ssh_user
        override.ssh.private_key_path = ssh_key 
        override.vm.provision :shell, path: "vagrant_provision/be.sh",
        env: {"DIST_DIR" => be_servers['dir']}
      end
    end
  end

  # Back-end load balancer
  config.vm.define "lb_be" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = project_id
      google.google_json_key_location = project_key
      google.tags = ['lb-be', 'http-server']

      google.zone = zone
      google.zone_config zone do |zone_config|
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
        env: { "PORT" => be_port, "TYPE" => "be"}

      # Send credentials to bastion (load balancer)
      override.trigger.after :up do |trigger|
        host = lb_be['external_ip']
        trigger.info = "Transferring ssh keys..."
        trigger.run = {
          path: "vagrant_provision/bastion_ssh.sh",
          args: [
            ssh_user, host, ssh_key, CFG['credentials'],
            be_servers['stable'], fe_servers['stable']
          ]
        }
      end
    end
  end

  # front-end load balancer
  config.vm.define "lb_fe" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = project_id
      google.google_json_key_location = project_key
      google.tags = ['fe-lb', 'http-server']

      google.zone = zone
      google.zone_config zone do |zone_config|
        zone_config.name = "eschool-lb-fe"
        zone_config.machine_type = "f1-micro"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-7"
        zone_config.network_ip = lb_fe['ip']
        zone_config.external_ip = lb_fe['external_ip']
      end

      override.ssh.username = ssh_user
      override.ssh.private_key_path = ssh_key
      override.vm.provision "lb",
        type: "shell",
        path: "vagrant_provision/lb.sh",
        args: fe_ips,
        env: { "PORT" => 80, "TYPE" => "fe"}
    end
  end

  # Front-end servers
  (0..fe_ips.length - 1).each do |i|
     server_ip = fe_ips[i]
     config.vm.define "fe#{i}" do |subconfig|
       subconfig.vm.provider :google do |google, override|
           google.google_project_id = project_id
           google.google_json_key_location = project_key
           google.tags = ['fe', 'http-server']

           google.zone = zone
           google.zone_config zone do |zone_config|
             zone_config.name = "eschool-fe#{i}"
             zone_config.machine_type = "f1-micro"
             zone_config.disk_size = "20"
             zone_config.image_family = "centos-7"
             zone_config.network_ip = server_ip
           end

           override.ssh.username = ssh_user
           override.ssh.private_key_path = ssh_key
           override.vm.provision "shell", path: "vagrant_provision/fe.sh",
           env: { "SSH_USER" => ssh_user }
       end
    end
  end
end
