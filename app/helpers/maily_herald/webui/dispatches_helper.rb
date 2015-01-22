module MailyHerald
  module Webui
    module DispatchesHelper
      def display_dispatch_state s
        content_tag(:span) do 
          case s.state
          when :enabled
            boolean_icon true, style: :toggle, text: :enabled
          when :disabled
            boolean_icon false, style: :toggle, text: :enabled
          when :archived
            icon("archive", tw("commons.archived"))
          end
        end
      end
    end
  end
end
