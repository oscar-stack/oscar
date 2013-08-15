require 'config_builder'

module Oscar
  module Runner
    def run(config_dir)
      ConfigBuilder.load(:yaml, :yamldir, config_dir)
    end
  end
end
