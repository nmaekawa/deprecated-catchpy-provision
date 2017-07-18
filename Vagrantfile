# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "catchpy" do |catchpy|
    # this box forces usr/pwd to login
    #catchpy.vm.box = "ubuntu/xenial64"
    catchpy.vm.box = "bento/ubuntu-16.04"
    catchpy.vm.network "private_network", ip: "10.3.3.3"

    catchpy.ssh.forward_agent = true
    catchpy.ssh.insert_key = false

    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    catchpy.vm.provider "virtualbox" do |v|
        v.memory = "4096"
    end

    catchpy.vm.provision "ansible" do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "playbook.yml"
        ansible.raw_arguments = [
          "-v"
        ]
    end
  end
end
