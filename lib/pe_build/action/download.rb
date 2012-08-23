require 'pebuild'
require 'pebuild/action'
require 'vagrant'

class PEBuild::Action::Download
  # Downloads a PE build to a temp directory

  BASENAME = 'pe_build'

  def initialize(app, env)
    @app = app
    @env = env

    @tempfile_path  = File.join(@env[:tmp_path], "#{BASENAME}-#{Time.now.to_s}")
    @tempfile       = File.new(@tempfile_path)

    @default_downloaders = [Vagrant::Downloaders::HTTP, Vagrant::Downloaders::File]

    @env[:pe_build] = {}
    @env[:pe_build][:tempfile_path] = @tempfile_path

  end

  def call(env)
    @env = env

    instantiate_downloader
    @downloader.download!(url, @tempfile)

    @app.call(@env)
  ensure
    cleanup_tempfile
  end

  # @return [String] The full URL to download, based on the config
  def url
    root     = @env.config.global.pe_build.download_root
    version  = @env.config.global.pe_build.default_version
    filename = @env.config.global.pe_build.filename

    [root, version, filename].join('/')
  end

  def instantiate_downloader
    all_downloaders = (@env["download.classes"] | @default_downloaders)
    downloader_class = all_downloaders.find { |downloader| downloader.match? self.url }

    raise "No downloader for #{self.url}" unless downloader_class
    @downloader = downloader_class.new(@nv[:ui])
  end

  alias_method :cleanup_tempfile, :recover
  def cleanup_tempfile(env = @env)
    @tempfile.close if(@tempfile and not @tempfile.closed?)
    File.unlink @tempfile_path if @tempfile_path
  end
end
