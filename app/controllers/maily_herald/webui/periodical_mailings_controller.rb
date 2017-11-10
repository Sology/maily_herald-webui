module MailyHerald
	class Webui::PeriodicalMailingsController < Webui::MailingsController
    add_breadcrumb :label_periodical_mailing_plural, Proc.new{ periodical_mailings_path }
    set_menu_item :periodical_mailings

    def show
      add_breadcrumb @item.title, Proc.new{ periodical_mailing_path(@item) }
      super
    end

    protected

    def set_resource_spec
      spec = super
      spec.params.push(:start_at, :period_in_days)
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
