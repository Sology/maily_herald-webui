require 'maily_herald/webui/version'

require 'smart_listing'
require 'haml'

if defined?(::Rails::Engine)
  require "maily_herald/webui/engine"
end

module MailyHerald
  module Webui
    autoload :Breadcrumbs,					'maily_herald/webui/breadcrumbs'
    autoload :MenuManager,					'maily_herald/webui/menu_manager'
  end
end
