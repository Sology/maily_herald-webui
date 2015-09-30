module MailyHerald
	class Webui::ListsController < Webui::ResourcesController
    add_breadcrumb :label_list_plural, Proc.new{ lists_path }
    set_menu_item :lists

    def subscribe
      find_item

      @entity = @item.context.model.find params[:entity_id]
      @item.subscribe! @entity
    end

    def unsubscribe
      find_item

      @entity = @item.context.model.find params[:entity_id]
      @item.unsubscribe! @entity
    end

    def context_attributes
      @context = MailyHerald.context(params[:context])

      render layout: "maily_herald/webui/modal"
    end

    protected

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::List
        spec.scope = Rails::VERSION::MAJOR == 3 ? MailyHerald::List.scoped : MailyHerald::List.all
        spec.filter_proc = Proc.new do |scope, query|
          scope.where("name like ? or title like ?", "%#{query}%", "%#{query}%")
        end
        spec.items_partial = "items"
        spec.params = [:name, :title, :context_name]
        spec.update_containers = {
          "subscribers" => true,
          "opt_outs" => true,
          "potential_subscribers" => true
        }
        spec.containers_order = ["details", "subscribers", "opt_outs", "potential_subscribers"]
      end
    end

    def action_dependencies *containers
      containers.flatten!

      @list = @item

      containers.each do |container|
        case container
        when "subscribers"
          @subscribers = @item.subscribers
          @subscribers = @subscribers.merge(@item.context.scope_like(params[:subscribers_filter])) if params[:subscribers_filter]
          @subscribers = smart_listing_create(:subscribers, @subscribers, :partial => "maily_herald/webui/subscribers/list")
        when "opt_outs"
          @opt_outs = @item.opt_outs
          @opt_outs = @opt_outs.merge(@item.context.scope_like(params[:opt_outs_filter])) if params[:opt_outs_filter]
          @opt_outs = smart_listing_create(:opt_outs, @opt_outs, :partial => "maily_herald/webui/subscribers/list")
        when "potential_subscribers"
          @potential_subscribers = @item.potential_subscribers
          @potential_subscribers = @potential_subscribers.merge(@item.context.scope_like(params[:potential_subscribers_filter])) if params[:potential_subscribers_filter]
          @potential_subscribers = smart_listing_create(:potential_subscribers, @potential_subscribers, :partial => "maily_herald/webui/subscribers/list")
        end
      end
    end
  end
end
