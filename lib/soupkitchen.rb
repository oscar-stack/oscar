module SoupKitchen; end

require 'soupkitchen/config'
require 'soupkitchen/command'
Vagrant.commands.register(:soupkitchen)     { SoupKitchen::Command }

