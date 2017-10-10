module MailyHerald
  module Webui
    class Engine < ::Rails::Engine
      isolate_namespace MailyHerald::Webui

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_girl, :dir => 'spec/support/factories'
      end
    end
  end
end
