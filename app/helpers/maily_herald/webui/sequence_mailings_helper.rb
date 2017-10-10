module MailyHerald
  module Webui
    module SequenceMailingsHelper
      def sequence_mailing_actions mailing
        actions = []
        actions << {
          name:      :show, 
          url:       sequence_mailing_path(mailing),
        }
      end
    end
  end
end
