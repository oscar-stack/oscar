require 'pe_build/config/pe_build'
Vagrant.config_keys.register(:pe_build)  { PEBuild::Config }
