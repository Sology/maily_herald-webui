module MailyHerald
  module Webui
    class ApplicationController < ActionController::Base
      include MailyHerald::Webui::Breadcrumbs::ControllerExtensions
      include MailyHerald::Webui::MenuManager::ControllerExtensions
      protect_from_forgery with: :exception

      helper SmartListing::Helper
      helper_method :settings

      before_action :set_time_zone

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

      def set_time_zone
        Time.zone = cookies["currentTimeZone"] || "UTC"
      end
    end
  end
end
