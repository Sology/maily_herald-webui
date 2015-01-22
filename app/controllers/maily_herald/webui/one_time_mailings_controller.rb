module MailyHerald
	class Webui::OneTimeMailingsController < Webui::MailingsController
    add_breadcrumb :label_one_time_mailing_plural, Proc.new{ one_time_mailings_path }
    set_menu_item :one_time_mailings

    def archived 
      add_breadcrumb view_context.tw("#{controller_name}.archived.label")
      
      super
    end

    def show
      add_breadcrumb @item.title || @item.name, one_time_mailing_path(@item)

      super
    end

    def deliver
      find_item

      if params[:entity_id]
        @e = @item.list.context.scope.find(params[:entity_id])
        @item.deliver_to @e

        render_containers ["logs"]
        render_update
      else
        @item.run
        head :ok
      end
    end

  end
end
