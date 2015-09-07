module MailyHerald
	class Webui::SubscriptionsController < Webui::ResourcesController
    add_breadcrumb :label_list_plural, Proc.new{ lists_path }
    set_menu_item :lists

    def show
      super

      @list = @item.list

      add_breadcrumb @list.title || @list.name, list_path(@list)

      add_breadcrumb view_context.tw("subscriptions.show.users_subscription", user: @item.entity.to_s)

      @entity = @item
      smart_listing_create(:processed_logs, @item.logs.processed, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
      smart_listing_create(:scheduled_logs, @item.logs.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
    end

    def toggle
      find_item
      @item.toggle!
    end

    protected

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::Subscription
      end
    end

    def action_dependencies *containers
    end
  end
end
