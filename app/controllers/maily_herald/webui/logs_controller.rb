module MailyHerald
	class Webui::LogsController < Webui::ResourcesController
    before_action :find_log
    before_action :load_preview, only: [:preview, :preview_html_template]

    add_breadcrumb :label_log_plural, Proc.new{ logs_path }
    set_menu_item :logs

    def retry
      @mailing = @log.mailing
      @log.retry

      @logs = smart_listing_create(:logs, @mailing.logs.processed, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      @schedules = smart_listing_create(:schedules, @mailing.logs.scheduled, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
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
