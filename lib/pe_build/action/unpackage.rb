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
    @extracted_dir = File.join(@env[:unpack_directory], destination_directory)
    extract_build
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

    @archive_path = File.join(PEBuild.archive_directory, @filename)
  end

  # Sadly, shelling out is more sane than trying to use the facilities
  # provided.
  def extract_build
    if File.directory? @extracted_dir
      @env[:ui].info "#{destination_directory} already present, skipping extraction."
    else
      cmd = %{tar xf #{@archive_path} -C #{@env[:unpack_directory]}}
      @env[:ui].info "Executing \"#{cmd}\""
      %x{#{cmd}}
    end
  rescue => e
    # If anything goes wrong while extracting, nuke the extracted directory
    # as it could be incomplete. If we do this, then we can ensure that if
    # the extracted directory already exists then it will be in a good state.
    @env[:ui].info "Removing possibly damaged installer directory '#{@extracted_dir}'"
    FileUtils.rm_r @extracted_dir
  end

  # Determine the name of the top level directory by peeking into the tarball
  def destination_directory
    raise "No such file \"#{@archive_path}\"" unless File.file? @archive_path

    IO.popen(%{tar -tf #{@archive_path}}) { |out| firstline = out.gets }

    raise "Unable to read installer archive #{@archive_path}" if $? != 0

    if firstline.nil? or firstline.empty?
      raise "Could not extract directory name from installer tarfile #{File.basename @archive_path}"
    elsif (match = firstline.match %r[^(.*?)/])
      match[1]
    end
  end
end
