module MailyHerald
  module Webui
    module LogsHelper
      def log_actions log
        actions = []
        subscription = log.mailing.list.subscription_for(log.entity) if log.mailing && log.entity
        actions << {
          name:      :custom, 
          url:       subscription_path(subscription),
          icon:      "fa fa-book",
          title:     tw("label_subscription")
        } if subscription && !@item.is_a?(Subscription)
        actions << {
          name: :custom, 
          url: preview_log_path(log), 
          icon: "fa fa-file-o", 
          data: {
            toggle: "modal", 
            target: "#modal-generic"
          }
        }
      end

      def display_log_status log
        case log.status
        when :delivered
          content_tag(:span, icon(:check, tw("logs.status.delivered")), class: "text-success")
        when :skipped
          content_tag(:span, icon(:times, tw("logs.status.skipped")), class: "text-warning")
        when :error
          content_tag(:span, icon(:exclamation, tw("logs.status.error")), class: "text-danger")
        when :scheduled
          content_tag(:span, icon(:"clock-o", tw("logs.status.scheduled")), class: "text-muted")
        end
      end

      def display_log_skip_reason skip_reason
        tw("logs.skip_reason.#{skip_reason}") if skip_reason
      end
    end
  end
end
