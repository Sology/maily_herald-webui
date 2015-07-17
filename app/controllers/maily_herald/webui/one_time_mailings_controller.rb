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
  end
end
