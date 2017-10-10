module MailyHerald
  module Webui
    module SequencesHelper
      def link_to_sequence sequence
        if sequence
          link_to url_for(sequence) do
            concat(friendly_name(sequence))
            if sequence.locked?
              concat("&nbsp;".html_safe)
              concat(icon(:lock))
            end
          end
        else
          tw("mailings.missing")
        end
      end
    end
  end
end
