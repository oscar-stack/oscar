
module Oscar
  module Runner
    def run(config_dir)
      require 'vagrant-hosts'
      require 'vagrant-pe_build'
      require 'vagrant-auto_network'
      require 'vagrant-config_builder'

      ConfigBuilder.load(:yaml, :yamldir, config_dir)
    end
  end
end
