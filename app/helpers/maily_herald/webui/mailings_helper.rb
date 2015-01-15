module MailyHerald
  module Webui
    module MailingsHelper
      def display_mailing_mailer mailer
        content_tag(:code, class: "mailing-mailer") do
          if mailer == :generic
            icon(:cubes, tw(:label_generic_mailer))
          else
            icon("file-code-o", mailer)
          end
        end
      end

      def display_mailing_state s
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

      def mailing_subscriber_actions mailing, entity
        actions = []
        actions << {
          name:      :custom, 
          url:       deliver_one_time_mailing_path(mailing, entity),
          icon:      "fa fa-paper-plane",
          title:     tw("mailings.list.deliver"),
          if:        mailing.processable?(entity),
          remote:    true,
          method:    :post
        }
        actions << {
          name:      :custom, 
          url:       preview_one_time_mailing_path(mailing, entity),
          icon:      "fa fa-search",
          title:     tw("mailings.list.preview"),
          data: {
            toggle: "modal", 
            target: "#modal-generic"
          }
        }
      end
    end
  end
end
