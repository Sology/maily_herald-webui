module MailyHerald
	class Webui::MailingsController < Webui::DispatchesController
    def update
      super

      case edited_container
      when "details"
        render_containers ["details", "template"]
      when "template"
        render_containers "template"
      end
    end

    def preview
      find_item

      @e = @item.list.context.scope.find(params[:entity_id])
      @mail = @item.build_mail @e

      render layout: "maily_herald/webui/modal"
    end

    protected

    def set_resource_spec
      Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = "MailyHerald::#{controller_name.classify}".constantize
        if Rails::VERSION::MAJOR == 3
          spec.scope = spec.klass.scoped
        else
          spec.scope = spec.klass.all
        end
        spec.filter_proc = Proc.new do |scope, query|
          scope.where("name like ? or title like ?", "%#{query}%", "%#{query}%")
        end
        spec.items_partial = "maily_herald/webui/mailings/list"
        spec.item_partial = "maily_herald/webui/mailings/mailing"
        spec.params = [:title, :mailer_name, :list, :from, :conditions, :override_subscription, :subject, :template]
        spec.update_containers = {
          "template" => {editable: true},
          "entities" => true,
          "logs" => true
        }
        spec.containers_order = ["details", "template", "entities", "logs"]
      end
    end

    def action_dependencies *containers
      containers.flatten!

      @mailing = @item
      @list = @mailing.list

      containers.each do |container|
        case container
        when "logs"
          @logs = smart_listing_create(:logs, @item.logs.processed, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
        when "entities"
          @entities = @item.list.subscribers
          @entities = @entities.merge(@item.list.context.scope_like(params[:entities_filter])) if params[:entities_filter]
          @entities = smart_listing_create(:entities, @entities, :partial => "maily_herald/webui/subscribers/list")
        else
          yield(container) if block_given?
        end
      end
    end
  end
end
