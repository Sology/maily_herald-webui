module MailyHerald
  module Webui
    module SubscriptionsHelper
      def display_subscription_state s
        content_tag(:span) do 
          boolean_icon s.active?
        end
      end
    end
  end
end
