module MailyHerald
  module Webui
    module SubscribersHelper
      def subscriber_actions list, entity
        actions = []
        subscription = MailyHerald::Subscription.get_from(entity) || list.subscription_for(entity)
        actions << {
          name:      :custom, 
          url:       subscription_path(subscription),
          icon:      "fa fa-book",
          title:     tw("label_subscription")
        } if subscription
        actions << {
          name:      :custom, 
          url:       !list.subscribed?(entity) ? subscribe_to_list_path(list, entity) : unsubscribe_from_list_path(list, entity),
          method:    :post, 
          icon:      !list.subscribed?(entity) ? "fa fa-square-o" : "fa fa-check-square-o", 
          remote:    true, 
          title:     !list.subscribed?(entity) ? tw("subscribers.item.subscribe") : tw("subscribers.item.unsubscribe"),
          confirm:   tw("subscriptions.show.toggle_confirm")
        }
      end
    end
  end
end
