module MailyHerald
  module Webui
    module MailingsHelper
      def display_mailing_mailer mailer
        if mailer == "generic"
          icon(:cubes, tw(:label_generic_mailer))
        else
          icon("file-code-o", mailer)
        end
      end
    end
  end
end
