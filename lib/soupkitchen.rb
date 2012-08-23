module SoupKitchen; end

require 'soupkitchen/config'
require 'soupkitchen/command'
Vagrant.commands.register(:soupkitchen)     { SoupKitchen::Command }

require 'vagrant/config/pe_build'
Vagrant.config_keys.register(:pe_build)  { Vagrant::Config::PEBuild }
