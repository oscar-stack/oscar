require 'yaml'

class Oscar::Command::InitVMs < Vagrant.plugin('2', :command)

  include Oscar::Command::Helpers

  def initialize(argv, env)
    @argv     = argv
    @env      = env
    @cmd_name = 'oscar init-vms'


    @masters = []
    @agents  = []
    @pe_version = '3.0.0' # @todo remove thingy

    split_argv
  end

  def execute
    argv = parse_options(parser)

    config_dir = Pathname.new(File.join(Dir.getwd, 'config'))

    vm_config_file = config_dir + 'vms.yaml'
    pe_config_file = config_dir + 'pe_build.yaml'

    config_dir.mkpath unless config_dir.exist?

    vm_config_file.open('w') do |fh|
      yaml = YAML.dump vms
      fh.write(yaml)
    end

    pe_config_file.open('w') do |fh|
      yaml = YAML.dump pe_build
      fh.write(yaml)
    end
  end

  private

  def parser
    OptionParser.new do |o|
      o.banner = "Usage: vagrant #{@cmd_name} [<args>]"
      o.separator ''

      o.on('-m', '--master=val', String, 'The name and basebox for a Puppet master') do |val|
        name, box = val.split('=')
        @masters << [name, box]
      end

      o.on('-a', '--agent=val', String, 'The name and basebox for a Puppet agent') do |val|
        name, box = val.split('=')
        @agents << [name, box]
      end

      o.on('-p', '--pe-version=val', String, 'The PE version to install on the VMs') do |val|
        @pe_version = val
      end
    end
  end

  def vms
    vm_list = []



    vm_list += @masters.map do |(name, box)|
      {
        'name'  => name,
        'box'   => box,
        'roles' => ['pe_puppetmaster']
      }
    end

    vm_list += @agents.map do |(name, box)|
      {
        'name'  => name,
        'box'   => box,
        'roles' => ['pe_puppetagent']
      }
    end

    {'vms' => vm_list}
  end

  def pe_build
    {'pe_build' => {'version' => @pe_version}}
  end
end
