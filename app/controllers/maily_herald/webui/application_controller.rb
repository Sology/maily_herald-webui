module MailyHerald
  module Webui
    class ApplicationController < ActionController::Base
      include MailyHerald::Webui::Breadcrumbs::ControllerExtensions
      include MailyHerald::Webui::MenuManager::ControllerExtensions

      helper SmartListing::Helper
      helper_method :expert_mode?, :work_mode

      def work_mode
        session[:work_mode].try(:to_sym) || :regular
      end

      def expert_mode?
        work_mode == :expert
      end
    end
  end
end
