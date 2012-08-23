require 'vagrant'

module PEBuild
  STORE_PATH = File.join(Vagrant::Environment::DEFAULT_HOME, "pe_builds")
end

require 'pe_build/action'

require 'pe_build/config'
Vagrant.config_keys.register(:pe_build) { PEBuild::Config }

require 'pe_build/command'
Vagrant.commands.register(:pe_build) { PEBuild::Command }
