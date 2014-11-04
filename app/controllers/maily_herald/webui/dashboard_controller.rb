module MailyHerald
	class Webui::DashboardController < Webui::ApplicationController
    include SmartListing::Helper::ControllerExtensions
    helper  SmartListing::Helper

    add_breadcrumb :label_dashboard, Proc.new{ lists_path }
    set_menu_item :dashboard

		def index
      smart_listing_create(:logs, MailyHerald::Log.delivered, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      smart_listing_create(:scheduled_logs, MailyHerald::Log.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
		end
	end
end
