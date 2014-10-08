module MailyHerald
  module Webui
    class Engine < ::Rails::Engine
      isolate_namespace MailyHerald::Webui

      config.generators do |g|
        g.test_framework      :rspec,         :fixture => false
        g.fixture_replacement :factory_girl,  :dir => 'spec/factories'
      end
      config.autoload_paths += Dir["#{config.root}/lib/**/"]

      initializer :assets do |config|
        Rails.application.config.assets.paths << root.join("vendor", "assets", "fonts")
        Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
      end
    end
  end
end
