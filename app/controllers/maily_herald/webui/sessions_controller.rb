module MailyHerald
	class Webui::SessionsController < Webui::ApplicationController
    def switch_setting
      settings.toggle params[:setting]

      if Rails::VERSION::MAJOR >= 5
        redirect_back(fallback_location: root_path)
      else
        redirect_to :back
      end
    end

    private

    def setting_cookie_name setting
      "maily_settings_#{setting}"
    end
  end
end
