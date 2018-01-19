module MailyHerald
	class Webui::LogsController < Webui::ResourcesController
    before_action :find_log

    add_breadcrumb :label_log_plural, Proc.new{ logs_path }
    set_menu_item :logs

    def retry
      @mailing = @log.mailing
      MailyHerald::Log.create_for @mailing, @log.entity, {status: :scheduled, processing_at: @log.processing_at}

      @logs = smart_listing_create(:logs, @mailing.logs.processed, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      @schedules = smart_listing_create(:schedules, @mailing.logs.scheduled, partial: "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
    end

    def preview
      render layout: "maily_herald/webui/modal"
    end

    def preview_html_template
      @template = @log.preview.html
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
  end
end
