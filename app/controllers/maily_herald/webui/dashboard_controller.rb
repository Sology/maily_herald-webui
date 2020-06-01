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

      @days = @period / 1.day
      @opened = {}
      @delivered = {}
      @error = {}
      @skipped = {}

      case @chosen_status
      when "processed"
        get_all_counted_logs
      when "opened"
        get_counted_logs_for :opened
      when "delivered"
        get_counted_logs_for :delivered
      when "skipped"
        get_counted_logs_for :skipped
      when "error"
        get_counted_logs_for :error
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
      @chosen_status && %w(processed opened delivered skipped error).include?(@chosen_status) ? logs(@chosen_status) : logs(:processed)
    end

    def get_all_counted_logs
      @processed_count = logs(:processed).count
      get_counted_logs_for :opened
      get_counted_logs_for :delivered
      get_counted_logs_for :skipped
      get_counted_logs_for :error
    end

    def get_counted_logs_for state
      count = instance_variable_set("@#{state}_count", logs(state).count)
      count_grouped = instance_variable_get("@#{state}")
      (0..@days).each { |i| count_grouped[(@time - i.days).strftime("%Y-%m-%d")] = 0 }

      count = logs(:delivered).count

      logs(state).each do |l|
        count_grouped[l.processing_at.strftime("%Y-%m-%d")] ||= 0
        count_grouped[l.processing_at.strftime("%Y-%m-%d")] += 1
      end
    end
	end
end
