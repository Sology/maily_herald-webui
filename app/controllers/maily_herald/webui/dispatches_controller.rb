module MailyHerald
	class Webui::DispatchesController < Webui::ResourcesController
    def index
      super do |scope|
        scope.not_archived
      end
    end

    def archived 
      self.class.superclass.instance_method(:index).bind(self).call do |scope|
        scope.archived
      end

      render "index"
    end

    def update_form
      new
      @item.attributes = item_params
    end

    def destroy
      @item.archive!

      render_containers ["details", "subscribers"]
      render_update
    end

    def toggle
      find_item

      unless @item.enabled?
        @item.enable!
      else
        @item.disable!
      end

      render_containers ["details", "subscribers"]
      render_update
    end
  end
end
