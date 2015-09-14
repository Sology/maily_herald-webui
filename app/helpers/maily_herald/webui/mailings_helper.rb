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
          url:       deliver_ad_hoc_mailing_path(mailing, entity),
          icon:      "fa fa-paper-plane",
          title:     tw("mailings.list.deliver"),
          if:        mailing.processable?(entity),
          remote:    true,
          method:    :post,
          data:      {confirm: tw("mailings.list.deliver_confirm")}
        } if mailing.ad_hoc?
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
          url_for(mailing)
        end
      end

      def link_to_mailing mailing
        if mailing
          link_to url_for_mailing(mailing) do
            concat(friendly_name(mailing))
            if mailing.locked?
              concat("&nbsp;".html_safe)
              concat(icon(:lock))
            end
          end
        else
          tw("mailings.missing")
        end
      end

      def display_mailing_from mailing
        mailing.from || tw("mailings.from.default", email: mailing.mailer.default[:from])
      end

      def display_mailing_period mailing
        #tw("commons.day", count: mailing.period_in_days)
        distance_of_time_in_words mailing.period
      end

      def display_mailing_absolute_delay mailing
        distance_of_time_in_words mailing.absolute_delay
      end

      def display_mailing_conditions mailing
        if mailing.has_conditions_proc?
          content_tag :span, class: "text-warning", data: {:toggle => "tooltip", :placement => "top"}, :title => tw("dispatches.hardcoded_info") do
            concat(icon(:gears))
            concat("&nbsp;".html_safe)
            concat(tw(:label_hardcoded))
          end
        elsif mailing.conditions.is_a?(String)
          content_tag(:code, mailing.conditions)
        else
          tw("mailings.conditions.missing")
        end
      end

      def display_mailing_conditions_status mailing, entity
        if mailing.conditions_met?(entity)
          content_tag(:span, icon(:check, tw("mailings.conditions.met")))
        else
          content_tag(:span, icon(:times, tw("mailings.conditions.unmet")), class: "text-warning")
        end
      end

      def display_mailing_start_at mailing
        if mailing.has_start_at_proc?
          content_tag :span, class: "text-warning", data: {:toggle => "tooltip", :placement => "top"}, :title => tw("dispatches.hardcoded_info") do
            concat(icon(:gears))
            concat("&nbsp;".html_safe)
            concat(tw(:label_hardcoded))
          end
        elsif mailing.start_at.is_a?(String)
          content_tag(:code, mailing.start_at)
        else
        end
      end
    end
  end
end
