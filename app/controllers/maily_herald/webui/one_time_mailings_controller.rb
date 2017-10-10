module MailyHerald
	class Webui::OneTimeMailingsController < Webui::MailingsController
    add_breadcrumb :label_one_time_mailing_plural, Proc.new{ one_time_mailings_path }
    set_menu_item :one_time_mailings

    def archived 
      add_breadcrumb view_context.tw("#{controller_name}.archived.label")
      
      super
    end

    def show
      super
    end

    protected

    def set_resource_spec
      spec = super
      spec.params.push(:start_at)
      spec.update_containers["schedules"] = true
      spec.containers_order = ["details", "template", "subscribers", "schedules", "logs"]
      spec
    end

    def action_dependencies *containers
      super do |container|
        case container
        when "schedules"
          @schedules = smart_listing_create(:schedules, @item.logs.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
        end
      end
    end
  end
end
