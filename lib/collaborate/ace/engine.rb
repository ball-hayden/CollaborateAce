module Collaborate
  module Ace
    class Engine < ::Rails::Engine
      isolate_namespace Collaborate::Ace

      config.generators do |g|
        g.test_framework :rspec
        g.factory_girl suffix: 'factory'
        g.helper false
        g.stylesheets false
        g.javascripts false
      end
    end
  end
end
