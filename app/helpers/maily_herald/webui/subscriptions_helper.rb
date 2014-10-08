module MailyHerald
  module Webui
    module SubscriptionsHelper
      def display_subscription_status s
        content_tag(:span) do 
          boolean_icon s.active?, :check
        end
      end
    end
  end
end
