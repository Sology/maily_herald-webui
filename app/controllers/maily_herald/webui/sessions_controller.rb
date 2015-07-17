module MailyHerald
	class Webui::SessionsController < Webui::ApplicationController
    def switch_setting
      settings.toggle params[:setting]

      redirect_to :back
    end

    private

    def setting_cookie_name setting
      "maily_settings_#{setting}"
    end
  end
end
