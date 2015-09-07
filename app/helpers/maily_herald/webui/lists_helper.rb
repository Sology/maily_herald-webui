module MailyHerald
  module Webui
    module ListsHelper
      def display_list_scope_status list, entity
        if list.context.scope.exists?(entity)
          content_tag(:span, icon(:check, tw("commons.positive")))
        else
          content_tag(:span, icon(:times, tw("commons.negative")), class: "text-warning")
        end
      end
    end
  end
end
