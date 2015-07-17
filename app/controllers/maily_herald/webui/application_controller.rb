module MailyHerald
  module Webui
    class ApplicationController < ActionController::Base
      include MailyHerald::Webui::Breadcrumbs::ControllerExtensions
      include MailyHerald::Webui::MenuManager::ControllerExtensions

      helper SmartListing::Helper
      helper_method :settings

      def settings
        Settings.new(cookies)
      end

      def log_scope
        if settings.show_skipped?
          MailyHerald::Log.all
        else
          MailyHerald::Log.not_skipped
        end
      end
    end
  end
end
