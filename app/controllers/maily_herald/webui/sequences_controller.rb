module MailyHerald
	class Webui::SequencesController < Webui::DispatchesController
    add_breadcrumb :label_sequence_plural, Proc.new{ sequences_path }
    set_menu_item :sequences

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
        spec.items_partial = "maily_herald/webui/sequences/list"
        spec.item_partial = "maily_herald/webui/sequences/sequence"
        spec.params = [:title, :list, :start_at, :override_subscription]
        spec.update_containers = {
          "mailings" => true,
          "entities" => true,
          "schedules" => true,
          "logs" => true
        }
        spec.containers_order = ["details", "mailings", "entities", "schedules", "logs"]
      end
    end

    def action_dependencies *containers
      containers.flatten!

      @sequence = @item
      @list = @sequence.list

      containers.each do |container|
        case container
        when "logs"
          @logs = smart_listing_create(:logs, @item.logs.processed, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
        when "schedules"
          @schedules = smart_listing_create(:schedules, @item.logs.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
        when "entities"
          @entities = @item.list.subscribers
          @entities = @entities.merge(@item.list.context.scope_like(params[:entities_filter])) if params[:entities_filter]
          @entities = smart_listing_create(:entities, @entities, :partial => "maily_herald/webui/subscribers/list")
        when "mailings"
          @mailings = smart_listing_create(:mailings, @item.mailings, :partial => "maily_herald/webui/mailings/list")
        else
          yield(container) if block_given?
        end
      end
    end
  end
end
