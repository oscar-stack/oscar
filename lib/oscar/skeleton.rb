require 'fileutils'

module Oscar
  class Skeleton

    # @!attribute [r] provider
    #   @return [Symbol] The provider for the generated configuration
    attr_reader :provider

    # @!attribute [r]
    #   @return [Pathname] The path to the destination directory
    attr_reader :dest_dir

    # @param env      [Vagrant::Environment]
    # @param provider [Symbol]
    def initialize(env, provider = nil)
      @env      = env
      @provider = (provider || @env.default_provider)
      @dest_dir = Pathname.new(Dir.getwd)

      @template_root = File.join(Oscar.template_root, 'oscar-init-skeleton')
    end

    def generate
      vagrantfile = File.join(@template_root, 'Vagrantfile')
      config_dir  = File.join(@template_root, @provider.to_s, '.')

      FileUtils.cp   vagrantfile, @dest_dir
      FileUtils.cp_r config_dir,  File.join(@dest_dir, 'config')
    end
  end
end
