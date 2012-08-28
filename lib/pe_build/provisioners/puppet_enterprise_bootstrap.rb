require 'pe_build/provisioners'
require 'vagrant'
require 'fileutils'

class PEBuild::Provisioners::PuppetEnterpriseBootstrap < Vagrant::Provisioners::Base

  class Config < Vagrant::Config::Base
    attr_writer :role

    def role
      @role || :agent
    end

    def validate
      errors.add("role must be one of [:master, :agent]") unless [:master, :agent].include role
    end
  end

  def self.config
    Config
  end

  def initialize(env, config)
    @env, @config = env, config

    load_variables

    @cache_path   = File.join(@env[:root_path], '.pe_build')
    @answers_dir  = File.join(@cache_path, 'answers')
  end

  def validate

  end

  def prepare
    prepare_cache_path
    prepare_installer
  end

  def provision!
    # determine if bootstrapping is necessary

    prepare_answers_file
    perform_installation
  end

  private

  # I HATE THIS.
  def load_variables
    if @env[:box_name]
      @root     = @env[:vm].pe_build.download_root
      @version  = @env[:vm].pe_build.version
      @filename = @env[:vm].pe_build.version
    end

    @root     ||= @env[:global_config].pe_build.download_root
    @version  ||= @env[:global_config].pe_build.version
    @filename ||= @env[:global_config].pe_build.filename

    @archive_path = File.join(PEBuild.archive_directory, @filename)
  end

  def prepare_cache_path
    FileUtils.mkdir @cache_path unless File.directory? @cache_path
  end

  def prepare_installer
    @env[:action_runner].run(:prep_build, :unpack_directory => @cache_path)
  end

  def prepare_answers_file
    FileUtils.mkdir_p @answers_dir unless File.directory? @answers_dir
  end

  # Perform the actual installation
  #
  # @todo Don't restrict this to the universal installer
  # @todo Don't always log the installation
  def perform_installation
    vm_base_dir = "/vagrant/.pe_build"
    installer   = "#{vm_base_dir}/puppet-enterprise-#{@version}-all/puppet-enterprise-installer"
    answers     = "#{vm_base_dir}/answers/#{@env[:vm].name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    cmd = <<-EOD
if [ -f /opt/puppet/bin/puppet ]; then
  echo "Puppet Enterprise version $(/opt/puppet/bin/puppet --version) already present."
  echo "Skipping installation."
else
  #{installer} -a #{answers} -l #{log_file}
fi
    EOD

    env[:vm].channel.sudo(cmd) do |type, data|
      # This section is directly ripped off from the shell provider.
      if [:stderr, :stdout].include?(type)
        color = type == :stdout ? :green : :red
        env[:ui].info(data.chomp, :color => color, :prefix => false)
      end
    end
  end
end
