# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "google/gce"

  config.vm.define "db" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = ENV["GCP_PROJECT_ID"]
      google.google_json_key_location = ENV["GCP_KEY"]

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-db"
        zone_config.machine_type = "g1-small"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-8"
        zone_config.network_ip = ENV["DB_SERVER_IP"]
      end

      override.vm.provision :shell, path: "vagrant_provision/db.sh",
      env: {
          "DATABASE" => ENV["DATABASE"],
          "DB_USER_NAME" => ENV["DB_USER_NAME"],
          "DB_USER_PWD" => ENV["DB_USER_PWD"],
          "DB_SERVER_IP" => ENV["DB_SERVER_IP"],
          "BE_SERVER_1" => ENV["BE_SERVER_1"],
          "BE_SERVER_2" => ENV["BE_SERVER_2"],
      }
      override.ssh.username = ENV["SSH_USER"]
      override.ssh.private_key_path = ENV["SSH_KEY"]
    end
  end

  config.vm.define "be1" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = ENV["GCP_PROJECT_ID"]
      google.google_json_key_location = ENV["GCP_KEY"]

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-be1"
        zone_config.machine_type = "g1-small"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-7"
        zone_config.network_ip = ENV["BE_SERVER_1"]
      end

      override.ssh.username = ENV["SSH_USER"]
      override.ssh.private_key_path = ENV["SSH_KEY"]
      override.vm.provision :shell, path: "vagrant_provision/be.sh"
    end
  end

  # todo install wget python3 + sudo pip3 install requests paramiko
  config.vm.define "lb_be" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = ENV["GCP_PROJECT_ID"]
      google.google_json_key_location = ENV["GCP_KEY"]
      google.tags = ['http-server']

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-lb-be"
        zone_config.machine_type = "f1-micro"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-7"
        zone_config.network_ip = ENV["BE_LB_IP"]
        zone_config.external_ip = ENV["LB_BE_EXT_IP"]
      end

      override.ssh.username = ENV["SSH_USER"]
      override.ssh.private_key_path = ENV["SSH_KEY"]
      override.vm.provision "shell", path: "vagrant_provision/lb.sh",
      env: {
          "SERVER_1" => ENV["BE_SERVER_1"],
          "SERVER_2" => ENV["BE_SERVER_2"],
          "PORT"     => ENV["BE_JAVA_PORT"],
      }
    end
  end

  config.vm.define "lb_fe" do |subconfig|
    subconfig.vm.provider :google do |google, override|
      google.google_project_id = ENV["GCP_PROJECT_ID"]
      google.google_json_key_location = ENV["GCP_KEY"]
      google.tags = ['http-server']

      google.zone = "europe-west3-c"
      google.zone_config "europe-west3-c" do |zone_config|
        zone_config.name = "eschool-lb-fe"
        zone_config.machine_type = "f1-micro"
        zone_config.disk_size = "20"
        zone_config.image_family = "centos-7"
        zone_config.network_ip = ENV["FE_LB_IP"]
      end

      override.ssh.username = ENV["SSH_USER"]
      override.ssh.private_key_path = ENV["SSH_KEY"]
      override.vm.provision "shell", path: "vagrant_provision/lb.sh",
      env: {
          "SERVER_1" => ENV["FE_SERVER_1"],
          "SERVER_2" => ENV["FE_SERVER_2"],
          "PORT"     => "80"
      }
    end
  end

  config.vm.define "fe1" do |subconfig|
    subconfig.vm.provider :google do |google, override|
        google.google_project_id = ENV["GCP_PROJECT_ID"]
        google.google_json_key_location = ENV["GCP_KEY"]
        google.tags = ['http-server']

        google.zone = "europe-west3-c"
        google.zone_config "europe-west3-c" do |zone_config|
          zone_config.name = "eschool-fe1"
          zone_config.machine_type = "f1-micro"
          zone_config.disk_size = "20"
          zone_config.image_family = "centos-7"
          zone_config.network_ip = ENV["FE_SERVER_1"]
        end

        override.ssh.username = ENV["SSH_USER"]
        override.ssh.private_key_path = ENV["SSH_KEY"]
        override.vm.provision "shell", path: "vagrant_provision/fe.sh",
        env: {
          "SSH_USER" => ENV["SSH_USER"]
        }
    end
  end
end
