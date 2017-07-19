# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # db node
  config.vm.define "postgres" do |postgres|
    # original box
    #postgres.vm.box = "ubuntu/trusty64"
    postgres.vm.box = "bento/ubuntu-16.04"
    postgres.vm.hostname = "postgresql"
    postgres.vm.network "private_network", ip: "10.3.3.4"

    postgres.ssh.insert_key = false

    postgres.vm.provider "virtualbox" do |v|
        v.memory = "4096"
    end

    #postgres.vm.provision "ansible" do |ansible|
    #    ansible.verbose = "vv"
    #    ansible.playbook = "playbook.yml"
    #end
  end

  # django webapp
  config.vm.define "catchpy" do |catchpy|
    # this box forces usr/pwd to login
    #catchpy.vm.box = "ubuntu/xenial64"
    catchpy.vm.box = "bento/ubuntu-16.04"
    catchpy.vm.hostname = "catchpy"
    catchpy.vm.network "private_network", ip: "10.3.3.3"

    catchpy.ssh.forward_agent = true
    catchpy.ssh.insert_key = false

    catchpy.vm.provider "virtualbox" do |v|
        v.memory = "4096"
    end

    #catchpy.vm.provision "ansible" do |ansible|
    #    ansible.verbose = "vv"
    #    ansible.playbook = "playbook.yml"
    #end
  end

end
