require 'pe_build'
require 'vagrant'

class PEBuild::Command::Download < Vagrant::Command::Base
  def execute
    @env.action_runner.run(:download_pe_build)
  end
end
