module MailyHerald
	class Webui::DashboardController < Webui::ApplicationController
    add_breadcrumb :label_dashboard, Proc.new{ lists_path }
    set_menu_item :dashboard

		def index
      render "maily_herald/webui/webui/index"
		end
	end
end
