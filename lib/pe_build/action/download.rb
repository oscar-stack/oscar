require 'pe_build'
require 'pe_build/action'
require 'vagrant'
require 'fileutils'

class PEBuild::Action::Download
  # Downloads a PE build to a temp directory

  def initialize(app, env)
    @app, @env = app, env

    load_variables

    @archive_path = File.join(PEBuild.archive_directory, @filename)
  end

  def call(env)
    @env = env
    perform_download
    @app.call(@env)
  end

  private

  def load_variables
    if @env[:box_name]
      @root     = @env[:vm].pe_build.download_root
      @version  = @env[:vm].pe_build.version
      @filename = @env[:vm].pe_build.version
    end

    @root     ||= @env[:global_config].pe_build.download_root
    @version  ||= @env[:global_config].pe_build.version
    @filename ||= @env[:global_config].pe_build.filename
  end

  # @return [String] The full URL to download, based on the config
  def url
    [@root, @version, @filename].join('/')
  end

  def perform_download
    p @env[:box_name]
    if File.exist? @archive_path
      @env[:ui].info "#{@archive_path} already present, skipping download."
    else
      Dir.chdir(PEBuild.archive_directory) { %x{curl -O #{url}} }
    end
  rescue => e
    File.unlink @archive_path if File.exist? @archive_path
    raise
  end
end
