require 'vagrant'

class PEBuild::Action::Download

  BASENAME = 'pe_build'

  def initialize(app, env)
    @app = app
    @env = env

    @default_downloaders = [Vagrant::Downloaders::HTTP, Vagrant::Downloaders::File]
  end

  def call(env)
    @env = env

    instantiate_downloader

    @app.call(@env)
  end

  def url
    root     = @env.config.global.pe_build.download_root
    version  = @env.config.global.pe_build.default_version
    filename = @env.config.global.pe_build.filename

    [root, version, filename].join('/')
  end

  def instantiate_downloader
    downloader_class = (@env["download.classes"] || @default_downloaders).find do |downloader|
      downloader.match? self.url
    end

    raise "No downloader for #{self.url}" unless downloader_class

    @downloader = downloader_class.new(@nv[:ui])
  end

  def download_package
  end
end
