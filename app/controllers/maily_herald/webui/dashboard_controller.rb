module MailyHerald
	class Webui::DashboardController < Webui::ApplicationController
    include SmartListing::Helper::ControllerExtensions
    helper  SmartListing::Helper

    add_breadcrumb :label_dashboard, Proc.new{ lists_path }
    set_menu_item :dashboard

		def index
      @chosen_period = params[:period]
      @chosen_status = params[:filter_by_status]

      @period = case @chosen_period
                when "week"
                  1.week
                when "6months"
                  6.months
                when "year"
                  1.year
                else #month
                  1.month
                end
      @time = Time.zone.now

      smart_listing_create(:logs, chosen_logs, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      smart_listing_create(:schedules, MailyHerald::Log.scheduled, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})

      days = @period / 1.day
      @delivered = {}
      @failed = {}
      @skipped = {}

      for i in 0..days
        @delivered[(@time - i.days).strftime("%Y-%m-%d")] = 0
        @failed[(@time - i.days).strftime("%Y-%m-%d")] = 0
        @skipped[(@time - i.days).strftime("%Y-%m-%d")] = 0
      end

      case @chosen_status
      when "processed"
        get_all_counted_logs
      when "delivered"
        @delivered_count = logs(:delivered).count

        logs(:delivered).each do |l|
          @delivered[l.processing_at.strftime("%Y-%m-%d")] ||= 0
          @delivered[l.processing_at.strftime("%Y-%m-%d")] += 1
        end
      when "skipped"
        @skipped_count = logs(:skipped).count

        logs(:skipped).each do |l|
          @skipped[l.processing_at.strftime("%Y-%m-%d")] ||= 0
          @skipped[l.processing_at.strftime("%Y-%m-%d")] += 1
        end
      when "error"
        @failed_count = logs(:error).count

        logs(:error).each do |l|
          @failed[l.processing_at.strftime("%Y-%m-%d")] ||= 0
          @failed[l.processing_at.strftime("%Y-%m-%d")] += 1
        end
      when nil
        get_all_counted_logs
      end
		end

    private

    def logs state, period = nil
      period ||= @period

      log_scope.send(state).where("processing_at > (?)", @time - period)
    end

    def chosen_logs
      @chosen_status && %w(processed delivered skipped error).include?(@chosen_status) ? logs(@chosen_status) : logs(:processed)
    end

    def get_all_counted_logs
        @total_count = log_scope.count
        @processed_count = logs(:processed).count
        @delivered_count = logs(:delivered).count
        @skipped_count = logs(:skipped).count
        @failed_count = logs(:error).count

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
	end
end
