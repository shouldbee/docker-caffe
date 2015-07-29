# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "shouldbee/ubuntu-14.04-with-docker"
  config.vm.box_version = "0.5"

  host = RbConfig::CONFIG['host_os']

  case host
  when /darwin/ # mac
    cpus = `sysctl -n hw.ncpu`.to_i
  when /linux/
    cpus = `nproc`.to_i
  else
    cpus = 2
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = cpus
  end
end
