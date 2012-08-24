require 'pe_build'
require 'pe_build/action'
require 'vagrant'
require 'fileutils'

class PEBuild::Action::Download
  # Downloads a PE build to a temp directory

  def initialize(app, env)
    @app, @env = app, env

    @archive_path = File.join(PEBuild.archive_directory, @env[:global_config].pe_build.filename)
  end

  def call(env)
    @env = env
    perform_download
    @app.call(@env)
  end

  private

  # @return [String] The full URL to download, based on the config
  def url
    root     = @env[:global_config].pe_build.download_root
    version  = @env[:global_config].pe_build.default_version
    filename = @env[:global_config].pe_build.filename

    [root, version, filename].join('/')
  end

  def perform_download
    if File.exist? @archive_path
      %x{curl -O #{@archive_path} #{url}}
    else
      @env[:ui].info "#{@archive_path} already present, skipping download."
    end
  rescue => e
    File.unlink @archive_path if File.exist? @archive_path
    raise
  end
end
