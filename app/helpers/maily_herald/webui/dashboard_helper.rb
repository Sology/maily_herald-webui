module MailyHerald
  module Webui
    module DashboardHelper
      def history_graph_data
        if @chosen_status
          {
            opened: {}.to_json,
            delivered: {}.to_json,
            skipped: {}.to_json,
            error: {}.to_json
          }.tap do |h|
            h[:opened] = @opened.to_json
            h[:delivered] = @delivered.to_json
            h[:skipped] = @skipped.to_json
            h[:error] = @error.to_json
            h
          end
        else
          h = {
            opened: @opened.to_json,
            delivered: @delivered.to_json,
            error: @error.to_json
          }
          h[:skipped] = @skipped.to_json if settings.show_skipped?
          h
        end
      end

      def summarized_status_link status, count, text, wrapper_class
        content_tag(:a, href: root_path(period: @chosen_period, filter_by_status: status), class: ["#{status.to_s}-count", ("active" if @chosen_status == status.to_s || !@chosen_status && status == :processed)], data: {remote: true}) do
          content_tag(:div, class: wrapper_class) do
            concat(content_tag(:strong, count ? count : tw("smart_listing.actions.show")))
            concat("<br/>".html_safe)
            concat(content_tag(:span, text))
          end
        end
      end

      def summarized_period_link period
        content_tag(:a, t(".#{period}"), href: root_path(period: period, filter_by_status: @chosen_status), class: ["link link-sm period-#{period}", ("active" if @chosen_period == period || !@chosen_period && period == "month")], data: {remote: true})
      end
    end
  end
end
