module MailyHerald
	class Webui::ResourcesController < Webui::ApplicationController
    include SmartListing::Helper::ControllerExtensions
    helper  SmartListing::Helper

    helper_method :resource_spec

    before_filter :find_item, :only => [:show, :edit, :update, :destroy]

    class Spec
      DEFAULT_CONTAINER = "details"
      attr_accessor :klass, :scope, :filter_proc, :items_partial, :item_partial, :locale_prefix, :params, :containers_order

      def filter scope, query
        @filter_proc.call(scope, query)
      end

      def update_containers
        @update_containers ||= {
          DEFAULT_CONTAINER => {editable: true}
        }
      end
      def update_containers= containers
        update_containers.merge!(containers)
      end
    end

    def index 
      scope = resource_spec.scope
      scope = resource_spec.filter(scope, params[:filter]) if params[:filter]

      if block_given?
        scope = yield(scope)
      end

      @items = smart_listing_create(:items, scope, :partial => resource_spec.items_partial || "items")
    end

    def new
      add_breadcrumb view_context.tw("#{controller_name}.new.label")

      @item = resource_spec.klass.new
    end

    def create
      @item = resource_spec.klass.new
      @item.attributes = item_params

      yield(@item) if block_given?

      if @item.save
        if @item.is_a?(MailyHerald::SequenceMailing)
          redirect_to sequence_mailing_path(@item.sequence, @item)
        else
          redirect_to @item
        end
      else
        add_breadcrumb view_context.tw("#{controller_name}.new.label", :action => :new)
        render :action => :new
      end
    end

    def show
      render_containers resource_spec.update_containers.keys
    end

    def edit
      set_edited_container
    end

    def update
      @item.update_attributes(item_params)

      render_containers resource_spec.update_containers.keys
      set_edited_container
    end

    def destroy
      @item.destroy

      flash[:notice] = "destroyed"

      redirect_to :action => :index
    end

    protected

    def resource_spec
      @resource_spec ||= set_resource_spec
    end

    private

    # Adds containers to list of containers to be updated (reloaded)
    def render_containers containers, options = {}
      containers = [*containers]

      if options[:append]
        @rendered_containers ||= []
        @rendered_containers.concat(containers.flatten)
      else
        @rendered_containers = containers
      end
    end

    # Sets main container which is editable
    def set_edited_container name = nil
      @edited_container = name || params[:edited_container] || Spec::DEFAULT_CONTAINER
    end
    def edited_container
      @edited_container
    end

    # Renders update template from different action
    def render_update 
      render action: "update"
    end

    # Collect container dependencies and render
    def render(options = {}, locals = {}, &block)
      collect_action_dependencies
      super
    end

    def find_item
      @item = resource_spec.klass.find params[:id]
    end

    # Run code required by rendered containers
    def collect_action_dependencies
      if @rendered_containers
        action_dependencies @rendered_containers
        #begin
          #action_dependencies @rendered_containers
        #rescue NoMethodError
        #end
      end
    end

    def item_params
      if Rails::VERSION::MAJOR == 3
        params[:item]
      else 
        params.require(:item).permit(*resource_spec.params)
      end
    end
  end
end
