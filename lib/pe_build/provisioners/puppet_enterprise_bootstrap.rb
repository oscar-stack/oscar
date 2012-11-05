require 'pe_build/provisioners'
require 'vagrant'
require 'fileutils'
require 'erb'

class PEBuild::Provisioners::PuppetEnterpriseBootstrap < Vagrant::Provisioners::Base

  class Config < Vagrant::Config::Base
    attr_writer :verbose

    def role=(rolename)
      @role = (rolename.is_a?(Symbol)) ? rolename : rolename.intern
    end

    def role
      @role || :agent
    end

    def verbose
      @verbose || true
    end

    def validate(env, errors)
      errors.add("role must be one of [:master, :agent]") unless [:master, :agent].include? role
    end
  end

  def self.config_class
    Config
  end

  def initialize(*args)
    super

    load_variables

    @cache_path   = File.join(@env[:root_path], '.pe_build')
    @answers_dir  = File.join(@cache_path, 'answers')
  end

  def validate(app, env)

  end

  def prepare
    FileUtils.mkdir @cache_path unless File.directory? @cache_path
    @env[:action_runner].run(:prep_build, :unpack_directory => @cache_path)
  end

  def provision!
    # determine if bootstrapping is necessary

    prepare_answers_file
    configure_installer

    [:pre, :provision, :post].each do |stepname|
      [:base, config.role].each do |rolename|
        step rolename, stepname
      end
    end
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

  def prepare_answers_file
    FileUtils.mkdir_p @answers_dir unless File.directory? @answers_dir
  end

  def step(role, stepname)
    script_dir  = File.join(@env[:root_path], 'bootstrap', role.to_s, stepname.to_s)
    script_list = Dir.glob("#{script_dir}/*")

    if script_list.empty?
      @env[:ui].info "No steps for #{role}/#{stepname}", :color => :cyan
    end

    script_list.each do |template_path|
      template = File.read(template_path)
      contents = ERB.new(template).result(binding)

      on_remote contents
    end
  end

  # Determine the proper invocation of the PE installer
  #
  # @todo Don't restrict this to the universal installer
  def configure_installer
    vm_base_dir = "/vagrant/.pe_build"
    installer   = "#{vm_base_dir}/puppet-enterprise-#{@version}-all/puppet-enterprise-installer"
    answers     = "#{vm_base_dir}/answers/#{@env[:vm].name}.txt"
    log_file    = "/root/puppet-enterprise-installer-#{Time.now.strftime('%s')}.log"

    @installer_cmd = "#{installer} -a #{answers} -l #{log_file}"
  end

  def on_remote(cmd)
    env[:vm].channel.sudo(cmd) do |type, data|
      # This section is directly ripped off from the shell provider.
      if type == :stdout and config.verbose
        @env[:ui].info(data.chomp, :color => :green, :prefix => false)
      elsif type == :stderr
        @env[:ui].info(data.chomp, :color => :red, :prefix => false)
      end
    end
  end
end
