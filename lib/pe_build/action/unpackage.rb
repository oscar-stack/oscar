require 'vagrant'
require 'pe_build/action'
require 'fileutils'

class PEBuild::Action::Unpackage
  def initialize(app, env)
    @app = app
    @env = env
  end

  def call(env)
    @env = env

    setup_pe_build_directory
    extract_build

    @app.call(@env)
  end

  def setup_pe_build_directory
    FileUtils.mkdir_p PEBuild::STORE_PATH
  end

  def extract_build
    Archive::Tar::Minitar.unpack(@env[:pe_build][:tempfile_path], PEBuild::STORE_PATH)
  end
end
