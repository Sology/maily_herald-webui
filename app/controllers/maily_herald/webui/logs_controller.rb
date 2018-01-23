module MailyHerald
	class Webui::LogsController < Webui::ResourcesController
    before_action :find_log
    before_action :load_preview, only: [:preview, :preview_html_template]

    add_breadcrumb :label_log_plural, Proc.new{ logs_path }
    set_menu_item :logs

    def retry
      @log.retry

      @is_dashboard = !request.referrer.match(/\/\d{1,}/)
      if @is_dashboard
        @period = case params[:period]
                  when "week"
                    1.week
                  when "6months"
                    6.months
                  when "year"
                    1.year
                  else
                    1.month
                  end

        @logs = log_scope.processed.where("processing_at > (?)", Time.zone.now - @period)
        @schedules = MailyHerald::Log.scheduled
      else
        @logs = @log.mailing.logs.processed
        @schedules = @log.mailing.logs.scheduled
      end

      smart_listing_create(:logs, @logs, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      smart_listing_create(:schedules, @schedules, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
    end

    def preview
      render layout: "maily_herald/webui/modal"
    end

    def preview_html_template
      render layout: false
    end

    protected

    def find_log
      @log = MailyHerald::Log.find params[:id]
    end

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::Log
      end
    end

    def load_preview
      @preview = @log.preview
    end
  end
end
