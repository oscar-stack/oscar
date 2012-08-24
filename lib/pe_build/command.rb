require 'pe_build'
require 'vagrant'

class PEBuild::Command < Vagrant::Command::Base
  def execute
    basedir = "#{@env.home_path}/soupkitchen"
    if File.directory? basedir
      Dir["#{@env.home_path}/soupkitchen/*"].each do |path|
        puts path
      end
    else
      warn "No PE versions downloaded."
    end
  end
end

require 'pe_build/command/list'
require 'pe_build/command/download'
