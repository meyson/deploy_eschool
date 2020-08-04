# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder ".", "/vagrant_data", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.memory = "700"
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
        "DB_SERVER_IP" => ENV["DB_SERVER_IP"],
        "BE_SERVER_1" => ENV["BE_SERVER_1"],
        "BE_SERVER_2" => ENV["BE_SERVER_2"],
    }
  end

  # Backend server 1
  config.vm.define "be1" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-be1.test"
    be.vm.network :private_network, ip: ENV["BE_SERVER_1"]
    be.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    be.vm.provision "shell", path: "vagrant_provision/be.sh"
  end

  # Backend server 2
  config.vm.define "be2" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-be2.test"
    be.vm.network :private_network, ip: ENV["BE_SERVER_2"]
    be.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    be.vm.provision "shell", path: "vagrant_provision/be.sh"
  end

  # Frontend server 1
  config.vm.define "fe1" do |fe|
    fe.vm.box = "centos/7"
    fe.vm.hostname = "orc-fe1.test"
    fe.vm.network :private_network, ip: ENV["FE_SERVER_1"]
    fe.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    fe.vm.provision "shell", path: "vagrant_provision/fe.sh",
    env: {
        "FE_VHOST_NAME" => ENV["FE_VHOST_NAME"]
    }
  end

  # Frontend server 2
  config.vm.define "fe2" do |fe|
    fe.vm.box = "centos/7"
    fe.vm.hostname = "orc-fe2.test"
    fe.vm.network :private_network, ip: ENV["FE_SERVER_2"]
    fe.vm.synced_folder "./build/#{ENV['DIST_DIR']}",
        "/#{ENV['DIST_DIR']}", disabled: false
    fe.vm.provision "shell", path: "vagrant_provision/fe.sh",
    env: {
        "FE_VHOST_NAME" => ENV["FE_VHOST_NAME"]
    }
  end

  # Frontend load balancer
  config.vm.define "fe-lb" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-fe-lb.test"
    be.vm.network :private_network, ip: ENV["FE_LB_IP"]
    be.vm.provision "shell", path: "vagrant_provision/fe_lb.sh",
    env: {
        "FE_SERVER_1" => ENV["FE_SERVER_1"],
        "FE_SERVER_2" => ENV["FE_SERVER_2"],
        "FE_LB_IP" => ENV["FE_LB_IP"],
    }
  end

  # Backend load balancer
  config.vm.define "be-lb" do |be|
    be.vm.box = "centos/7"
    be.vm.hostname = "orc-be-lb.test"
    be.vm.network :private_network, ip: ENV["BE_LB_IP"]
    be.vm.provision "shell", path: "vagrant_provision/be_lb.sh",
    env: {
        "BE_SERVER_1" => ENV["BE_SERVER_1"],
        "BE_SERVER_2" => ENV["BE_SERVER_2"],
        "BE_LB_IP" => ENV["BE_LB_IP"],
        "BE_JAVA_PORT" => ENV["BE_JAVA_PORT"],
    }
  end
end
