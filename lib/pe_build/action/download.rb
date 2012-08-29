require 'pe_build'
require 'pe_build/action'
require 'vagrant'
require 'fileutils'

class PEBuild::Action::Download
  # Downloads a PE build to a temp directory

  def initialize(app, env)
    @app, @env = app, env
    load_variables
  end

  def call(env)
    @env = env
    perform_download
    @app.call(@env)
  end

  private

  # Determine system state and download a PE build accordingly.
  #
  # If we are applying actions within the context of a single box, then we
  # should try to prefer and box level configuration options first. If
  # anything is unset then we should fall back to the global settings.
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

  # @return [String] The full URL to download, based on the config
  def url
    [@root, @version, @filename].join('/')
  end

  def perform_download
    if File.exist? @archive_path
      @env[:ui].info "#{@archive_path} already present, skipping download."
    else
      FileUtils.mkdir_p PEBuild.archive_directory unless File.directory? PEBuild.archive_directory
      cmd = %{curl -A "Vagrant/PEBuild (v#{PEBuild::Version})" -O #{url}}
      @env[:ui].info "Executing \"#{cmd}\""
      Dir.chdir(PEBuild.archive_directory) { %x{#{cmd}} }
    end
  end

  def recover(env)
    @env = env
    File.unlink @archive_path if File.exist? @archive_path
  end
end
