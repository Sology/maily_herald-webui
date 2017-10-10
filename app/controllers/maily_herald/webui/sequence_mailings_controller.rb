module MailyHerald
	class Webui::SequenceMailingsController < Webui::MailingsController
    add_breadcrumb :label_sequence_plural, Proc.new{ sequences_path }
    set_menu_item :sequences

    before_filter :find_sequence

    def new
      super
      @item.sequence = @sequence
    end

    def create
      super do |mailing|
        mailing.sequence = @sequence
      end
    end

    protected

    def find_sequence
      @sequence = MailyHerald::Sequence.find(params[:sequence_id])
      add_breadcrumb view_context.friendly_name(@sequence), Proc.new{ sequence_path(@sequence) }
    end

    def set_resource_spec
      spec = super
      spec.params.push(:absolute_delay_in_days)
      spec.update_containers["schedules"] = true
      spec.containers_order = ["details", "template", "subscribers", "schedules", "logs"]
      spec
    end

    def action_dependencies *containers
      super do |container|
        case container
        when "schedules"
          @schedules = smart_listing_create(:schedules, @item.logs.scheduled, :partial => "maily_herald/webui/logs/items", default_sort: {processing_at: "asc"})
        end
      end
    end
  end
end
