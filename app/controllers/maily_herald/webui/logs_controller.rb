module MailyHerald
	class Webui::LogsController < Webui::ResourcesController
    add_breadcrumb :label_log_plural, Proc.new{ logs_path }
    set_menu_item :logs

    def preview
      @log = MailyHerald::Log.find params[:id]

      render layout: "maily_herald/webui/modal"
    end

    protected

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::Log
      end
    end
  end
end
