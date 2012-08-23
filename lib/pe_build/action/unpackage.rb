require 'vagrant'

class PEBuild::Action::Unpackage
  def initialize(app, env)
    @app = app
    @env = env
  end

  def call(env)
    @nv = env
  end
end
