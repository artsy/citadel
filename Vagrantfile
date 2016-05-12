# -*- mode: ruby -*-
# vi: set ft=ruby :
#

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = false
    config.cache.enable :apt
    config.cache.enable :gem
    config.cache.enable :chef
  end

  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = 'latest'
  end

  config.vm.define "citadel" do |vb|
    vb.vm.box = "inofficial-ubuntu-1404-amd64"
    vb.vm.box_url = "https://github.com/kraksoft/vagrant-box-ubuntu/releases/download/14.04/ubuntu-14.04-amd64.box"

   vb.vm.network :private_network, type: 'dhcp'

   vb.berkshelf.enabled = true
   vb.berkshelf.berksfile_path = "./Berksfile"

   vb.vm.provider "virtualbox" do |vbs|
      vbs.customize ["modifyvm", :id, "--memory", 512]
   end

   vb.vm.hostname = "citadel"

     vb.vm.provision "chef_zero" do |chef|

       chef.log_level = :warn

       chef.cookbooks_path = "."
       chef.nodes_path = "./nodes"
       chef.json = {
        :citadel => {
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
          :kms_key_id => ENV['CITADEL_KEY_ID']
        }
       }

       chef.run_list = [
         'recipe[citadel::default]'
       ]

    end
  end

end
