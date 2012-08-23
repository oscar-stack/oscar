module SoupKitchen; end

require 'soupkitchen/config'
require 'soupkitchen/command'
require 'vagrant/config/pe'

Vagrant.config_keys.register(:soupkitchen)  { Vagrant::Config::SoupKitchen }
Vagrant.commands.register(:soupkitchen)     { SoupKitchen::Command }
