require 'vagrant'
class PEBuild::Command::List < Vagrant::Command::Base
  def execute
    if File.directory? PEBuild.archive_directory and (entries = Dir["#{PEBuild.archive_directory}/*"])
      puts entries.join('\n')
    else
      warn "No PE versions downloaded."
    end
  end
end
