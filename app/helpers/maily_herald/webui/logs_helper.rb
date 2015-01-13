module MailyHerald
  module Webui
    module LogsHelper
      def log_actions log
        actions = []
        subscription = log.mailing.list.subscription_for(log.entity) if log.entity
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
          if: log.delivered?, 
          data: {
            toggle: "modal", 
            target: "#modal-generic"
          }
        }
      end
    end
  end
end
