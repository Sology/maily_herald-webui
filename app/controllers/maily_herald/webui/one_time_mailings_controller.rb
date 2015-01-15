module MailyHerald
	class Webui::OneTimeMailingsController < Webui::ResourcesController
    add_breadcrumb :label_one_time_mailing_plural, Proc.new{ one_time_mailings_path }
    set_menu_item :one_time_mailings

    def index
      super do |scope|
        scope.not_archived
      end
    end

    def archived 
      add_breadcrumb view_context.tw("#{controller_name}.archived.label")

      self.class.superclass.instance_method(:index).bind(self).call do |scope|
        scope.archived
      end

      render "index"
    end

    def template
      new
      @item.attributes = item_params
    end

    def show
      super

      add_breadcrumb @item.title || @item.name, one_time_mailing_path(@item)
    end

    def update
      super

      case edited_container
      when "details"
        render_containers ["details", "template"]
      when "template"
        render_containers "template"
      end
    end

    def destroy
      @item.archive!

      flash[:notice] = "archived"

      redirect_to :action => :show
    end

    def toggle
      find_item

      unless @item.enabled?
        @item.enable!
      else
        @item.disable!
      end

      render_containers ["details", "entities"]
      render_update
    end

    def deliver
      find_item

      @e = @item.list.context.scope.find(params[:entity_id])
      @log = @item.deliver_to @e

      render_containers ["logs"]
      render_update
    end

    protected

    def resource_spec
      @resource_spec ||= Webui::ResourcesController::Spec.new.tap do |spec|
        spec.klass = MailyHerald::OneTimeMailing
        if Rails::VERSION::MAJOR == 3
          spec.scope = MailyHerald::OneTimeMailing.scoped
        else
          spec.scope = MailyHerald::OneTimeMailing.all
        end
        spec.filter_proc = Proc.new do |scope, query|
          scope.where("name like ? or title like ?", "%#{query}%", "%#{query}%")
        end
        spec.items_partial = "maily_herald/webui/mailings/list"
        spec.item_partial = "maily_herald/webui/mailings/mailing"
        spec.params = [:title, :mailer_name, :list, :conditions, :override_subscription, :subject, :template]
        spec.update_containers = {
          "template" => {editable: true},
          "entities" => true,
          "logs" => true
        }
      end
    end

    def action_dependencies *containers
      containers.flatten!

      @mailing = @item
      @list = @mailing.list

      containers.each do |container|
        case container
        when "logs"
          @logs = smart_listing_create(:logs, @item.logs, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})
        when "entities"
          @entities = @item.list.subscribers
          @entities = @entities.merge(@item.list.context.scope_like(params[:entities_filter])) if params[:entities_filter]
          @entities = smart_listing_create(:entities, @entities, :partial => "maily_herald/webui/subscribers/list")
        end
      end
    end
  end
end
