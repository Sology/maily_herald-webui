module MailyHerald
	class Webui::SessionsController < Webui::ApplicationController
    def switch_mode
      if %w{regular expert}.include? params[:mode]
        session[:work_mode] = params[:mode].to_sym
      end

      redirect_to :back
    end
  end
end
