module MailyHerald
	class Webui::MailingsController < Webui::DispatchesController
    before_action :load_preview, only: [:preview, :preview_html_template]

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
      render layout: "maily_herald/webui/modal"
    end

    def preview_html_template
      @template = @preview.is_a?(String) ? @preview : @preview.html
      render layout: false
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
        spec.params = [:name, :title, :mailer_name, :list, :from, :conditions, :subject, :template_plain, :template_html, :kind, :track]
        spec.update_containers = {
          "template" => {editable: true},
          "subscribers" => true,
          "logs" => true,
          "schedules" => true
        }
        spec.containers_order = ["details", "template", "subscribers", "logs", "schedules"]
      end
    end

    def action_dependencies *containers
      containers.flatten!

      @mailing = @item
      @list = @mailing.list

      containers.each do |container|
        case container
        when "logs"
          @logs = @item.logs.merge(log_scope)
          @logs = case params[:logs_status_filter]
                  when "processed"
                    @logs.processed
                  when "opened"
                    @logs.opened
                  when "delivered"
                    @logs.delivered
                  when "skipped"
                    @logs.skipped
                  when "error"
                    @logs.error
                  else
                    @logs.processed
                  end
          @logs = @logs.merge(MailyHerald::Log.like_email(params[:logs_filter])) if params[:logs_filter]
          @logs = smart_listing_create(:logs, @logs, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "desc"})

        when "schedules"
          @schedules = @item.logs.scheduled
          @schedules = @schedules.merge(MailyHerald::Log.like_email(params[:schedules_filter])) if params[:schedules_filter]
          @schedules = smart_listing_create(:schedules, @schedules, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})

        when "subscribers"
          @with_unmet_conditions = params[:with_unmet_conditions] == "1"

          @subscribers = @item.list.subscribers
          @subscribers = @subscribers.merge(@item.list.context.scope_like(params[:subscribers_filter])) if params[:subscribers_filter]
          @subscribers = @subscribers.select{|e| @mailing.conditions_met?(e)} if @mailing.has_conditions? && params[:with_unmet_conditions] != "1"
          @subscribers = smart_listing_create(:subscribers, @subscribers, :partial => "maily_herald/webui/subscribers/list", array: @mailing.has_conditions?)
        else
          yield(container) if block_given?
        end
      end
    end

    def load_preview
      find_item
      @preview =  if params[:entity_id].present?
                    @e = @item.list.context.scope.find(params[:entity_id])
                    @mail = @item.build_mail @e
                    MailyHerald::Mailing::Preview.new @mail
                  else
                    @item.template.html
                  end
    end
  end
end
