
module SoupKitchen

  def self.facehug!(directory)
    env = SoupKitchen::Environment.new
    env.config.load! directory
    env.run!

    env
  end
end

require 'soupkitchen/config'
require 'soupkitchen/environment'
require 'soupkitchen/node'
