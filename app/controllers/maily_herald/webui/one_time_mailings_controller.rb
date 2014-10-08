module MailyHerald
	class Webui::OneTimeMailingsController < Webui::ResourcesController
    add_breadcrumb :label_one_time_mailing_plural, Proc.new{ one_time_mailings_path }
    set_menu_item :one_time_mailings

    def index
      view_context.content_for :nav_secondary, "dsdf"
      super
    end

    protected

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::OneTimeMailing
        spec.scope = MailyHerald::OneTimeMailing.scoped
        spec.filter_proc = Proc.new do |scope, query|
          scope.where("name like ? or title like ?", "%#{query}%", "%#{query}%")
        end
        spec.items_partial = "maily_herald/webui/mailings/list"
        spec.item_partial = "maily_herald/webui/mailings/mailing"
      end
    end
  end
end
