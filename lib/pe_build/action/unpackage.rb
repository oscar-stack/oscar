require 'vagrant'
require 'pe_build/action'
require 'fileutils'

class PEBuild::Action::Unpackage
  def initialize(app, env)
    @app, @env = app, env
    load_variables
  end

  def call(env)
    @env = env
    extract_build
    @app.call(@env)
  end

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

  # Sadly, shelling out is more sane than trying to use the facilities
  # provided.
  def extract_build
    cmd = %{tar xf #{@archive_path} -C #{@env[:unpack_directory]}}
    @env[:ui].info "Executing \"#{cmd}\""
    %x{#{cmd}}
  end
end
