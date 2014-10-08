module MailyHerald
	class Webui::ResourcesController < Webui::ApplicationController
    include SmartListing::Helper::ControllerExtensions
    helper  SmartListing::Helper

    helper_method :resource_spec

    before_filter :find_item, :only => [:show, :edit, :update, :destroy]

    class Spec
      attr_accessor :klass, :scope, :filter_proc, :items_partial, :item_partial, :locale_prefix

      def filter scope, query
        @filter_proc.call(scope, query)
      end
    end

    def index 
      scope = resource_spec.scope
      scope = resource_spec.filter(scope, params[:filter]) if params[:filter]

      @items = smart_listing_create(:items, scope, :partial => resource_spec.items_partial || "items")
    end

    def new
      add_breadcrumb view_context.tw("#{controller_name}.new.label")

      @item = resource_spec.klass.new
    end

    def create
      @item = resource_spec.klass.new
      @item.attributes = item_params
      if @item.save
        redirect_to @item
      else
        add_breadcrumb view_context.tw("#{controller_name}.new.label", :action => :new)
        render :action => :new
      end
    end

    def show
    end

    def edit
    end

    def update
      @item.update_attributes(item_params)
    end

    def destroy
      @item.destroy

      flash[:notice] = "destroyed"

      redirect_to :action => :index
    end

    private

    def find_item
      @item = resource_spec.klass.find params[:id]
    end

    def item_params
      params[:item]
    end
  end
end
