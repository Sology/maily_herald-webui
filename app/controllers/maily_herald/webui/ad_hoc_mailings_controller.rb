module MailyHerald
	class Webui::AdHocMailingsController < Webui::MailingsController
    add_breadcrumb :label_ad_hoc_mailing_plural, Proc.new{ ad_hoc_mailings_path }
    set_menu_item :ad_hoc_mailings

    def archived 
      add_breadcrumb view_context.tw("#{controller_name}.archived.label")
      
      super
    end

    def show
      super
    end

    def deliver
      find_item

      if params[:entity_id]
        @e = @item.list.context.scope.find(params[:entity_id])
        @item.schedule_delivery_to @e

        render_containers ["schedules"]
        render_update
      else
        @item.schedule_delivery_to_all

        render_containers ["schedules"]
        render_update
      end
    end
  end
end
