require 'vagrant'

module PEBuild
  def self.archive_directory
    File.expand_path(File.join(ENV['HOME'], '.vagrant.d', 'pe_builds'))
  end
end

require 'pe_build/action'

require 'pe_build/config'
Vagrant.config_keys.register(:pe_build) { PEBuild::Config }

require 'pe_build/command'
Vagrant.commands.register(:pe_build) { PEBuild::Command }
