# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant_data", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = "1024"
    vb.cpus = 2
  end

  # DB Server 1
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/bionic64"
    db.vm.hostname = "orc-db.test"
    db.vm.network :private_network, ip: ENV["DB_SERVER_IP"]
    db.vm.provision "shell", path: "vagrant_provision/db.sh",
    env: {
        "DATABASE" => ENV["DATABASE"],
        "DB_USER_NAME" => ENV["DB_USER_NAME"],
        "DB_USER_PWD" => ENV["DB_USER_PWD"],
        "DB_USER_HOST" => ENV["BE_SERVER_IP"],
        "DB_SERVER_IP" => ENV["DB_SERVER_IP"]
    }
  end

  # Backend server
  config.vm.define "be" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-be.test"
    be.vm.network :private_network, ip: ENV["BE_SERVER_IP"]
    be.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    be.vm.provision "shell", path: "vagrant_provision/be.sh",
    env: {
        "DIST_DIR_BE" => ENV["DIST_DIR_BE"],
    }
  end

  # Frontend server
  config.vm.define "fe" do |fe|
    fe.vm.box = "centos/7"
    fe.vm.hostname = "orc-fe.test"
    fe.vm.network :private_network, ip: ENV["FE_SERVER_IP"]
    fe.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    fe.vm.provision "shell", path: "vagrant_provision/fe.sh",
    env: {
        "FE_VHOST_NAME" => ENV["FE_VHOST_NAME"]
    }
  end
end
