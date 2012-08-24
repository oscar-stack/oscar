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

    @cache_path = File.join(@env[:root_path], '.pe_build')
  end

  def validate

  end

  def prepare
    prepare_cache_path
    prepare_installer
  end

  def provision!

  end

  private

  def prepare_cache_path
    FileUtils.mkdir @cache_path unless File.directory? @cache_path
  end

  def prepare_installer
    @env[:action_runner].run(:prep_build, :unpack_directory => @cache_path)
  end
end
