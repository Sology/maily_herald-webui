module MailyHerald
  module Webui
    module DashboardHelper
      def history_graph_data
        h = {
          delivered: @delivered.to_json, 
          failed: @failed.to_json, 
        }
        h[:skipped] = @skipped.to_json if settings.show_skipped?
        h
      end
    end
  end
end
