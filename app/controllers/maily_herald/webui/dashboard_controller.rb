module MailyHerald
	class Webui::DashboardController < Webui::ApplicationController
    include SmartListing::Helper::ControllerExtensions
    helper  SmartListing::Helper

    add_breadcrumb :label_dashboard, Proc.new{ lists_path }
    set_menu_item :dashboard

		def index
      @period = case params[:period]
                when "week"
                  1.week
                when "6months"
                  6.months
                when "year"
                  1.year
                else #month
                  1.month
                end
      @time = Time.now

      smart_listing_create(:logs, logs(:processed), :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      smart_listing_create(:scheduled_logs, MailyHerald::Log.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})

      @total_count = log_scope.count
      @processed_count = logs(:processed).count
      @delivered_count = logs(:delivered).count
      @skipped_count = logs(:skipped).count
      @failed_count = logs(:error).count

      days = @period / 1.day
      @delivered = {}
      @failed = {}
      @skipped = {}

      for i in 0..days
        @delivered[(@time - i.days).strftime("%Y-%m-%d")] = 0
        @failed[(@time - i.days).strftime("%Y-%m-%d")] = 0
        @skipped[(@time - i.days).strftime("%Y-%m-%d")] = 0
      end


      logs(:delivered).each do |l| 
        @delivered[l.processing_at.strftime("%Y-%m-%d")] ||= 0
        @delivered[l.processing_at.strftime("%Y-%m-%d")] += 1
      end
      logs(:error).each do |l| 
        @failed[l.processing_at.strftime("%Y-%m-%d")] ||= 0
        @failed[l.processing_at.strftime("%Y-%m-%d")] += 1
      end
      logs(:skipped).each do |l| 
        @skipped[l.processing_at.strftime("%Y-%m-%d")] ||= 0
        @skipped[l.processing_at.strftime("%Y-%m-%d")] += 1
      end
		end

    private

    def logs state, period = nil
      period ||= @period

      log_scope.send(state).where("processing_at > (?)", @time - period)
    end
	end
end
