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
        } if mailing.one_time?
        actions << {
          name:      :custom, 
          url:       {action: :preview, id: mailing, entity_id: entity},
          icon:      "fa fa-search",
          title:     tw("mailings.list.preview"),
          data: {
            toggle: "modal", 
            target: "#modal-generic"
          }
        }
      end

      def url_for_mailing mailing
        if mailing.sequence?
          sequence_mailing_path(mailing.sequence_id, mailing)
        else
          mailing_path(mailing)
        end
      end

      def link_to_mailing mailing
        link_to friendly_name(mailing), url_for_mailing(mailing)
      end

      def display_mailing_from mailing
        tw("mailings.from.default", email: mailing.mailer.default[:from])
      end

      def display_mailing_period mailing
        #tw("commons.day", count: mailing.period_in_days)
        distance_of_time_in_words mailing.absolute_delay
      end

      def display_mailing_absolute_delay mailing
        distance_of_time_in_words mailing.absolute_delay
      end
    end
  end
end
