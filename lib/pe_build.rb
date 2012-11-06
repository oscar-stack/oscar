require 'vagrant'

module PEBuild
  def self.archive_directory
    File.expand_path(File.join(ENV['HOME'], '.vagrant.d', 'pe_builds'))
  end

  def self.source_root
    @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end

require 'pe_build/version'
require 'pe_build/action'
require 'pe_build/config'
require 'pe_build/command'
require 'pe_build/provisioners'
