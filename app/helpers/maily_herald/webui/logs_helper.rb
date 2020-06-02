module MailyHerald
  module Webui
    module LogsHelper
      def log_actions log
        actions = []
        subscription = log.mailing.list.subscription_for(log.entity) if log.mailing && log.entity
        actions << {
          name:     :custom,
          url:      retry_log_path(log),
          method:   :post,
          icon:     "fa fa-refresh",
          title:    tw("label_retry"),
          data: {
            remote: :true
          }
        } if log.error?
        actions << {
          name:      :custom,
          url:       subscription_path(subscription),
          icon:      "fa fa-book",
          title:     tw("label_subscription")
        } if subscription && !@item.is_a?(Subscription)
        actions << {
          name:     :custom,
          url:      preview_log_path(log),
          icon:     "fa fa-file-o",
          title:    tw("label_preview"),
          data: {
            toggle: "modal",
            target: "#modal-generic"
          }
        }
        actions
      end

      def display_clicks_for log
        keys = log.clicks.list.first.keys.reverse
        content_tag(:table, class: "table table-striped") do
          concat(content_tag(:thead) do
            concat(content_tag(:tr) do
              keys.each do |k|
                concat(content_tag(:th, k.to_s.capitalize.gsub("_", " "), class: k == :user_agent ? "" : "col-sm-3"))
              end
            end)
          end)
          concat(content_tag(:thead) do
            concat(content_tag(:tbody) do
              log.clicks.list.each do |o|
                concat(content_tag(:tr) do
                  keys.each do |k|
                    concat(content_tag(:td, o[k].is_a?(Time) ? o[k].in_time_zone.strftime("%Y-%m-%d %H:%M") : o[k]))
                  end
                end)
              end
            end)
          end)
        end
      end

      def display_opens_for log
        keys = log.opens.list.first.keys.reverse
        content_tag(:table, class: "table table-striped") do
          concat(content_tag(:thead) do
            concat(content_tag(:tr) do
              keys.each do |k|
                concat(content_tag(:th, k.to_s.capitalize.gsub("_", " "), class: k == :user_agent ? "" : "col-sm-3"))
              end
            end)
          end)
          concat(content_tag(:thead) do
            concat(content_tag(:tbody) do
              log.opens.list.each do |o|
                concat(content_tag(:tr) do
                  keys.each do |k|
                    concat(content_tag(:td, o[k].is_a?(Time) ? o[k].in_time_zone.strftime("%Y-%m-%d %H:%M") : o[k]))
                  end
                end)
              end
            end)
          end)
        end
      end

      def display_delivery_attempts_for log
        keys = log.delivery_attempts.list.first.keys
        content_tag(:table, class: "table table-striped") do
          concat(content_tag(:thead) do
            concat(content_tag(:tr) do
              keys.each do |k|
                concat(content_tag(:th, k.to_s.capitalize.gsub("_", " "), class: k == :date_at ? "col-sm-3" : ""))
              end
            end)
          end)
          concat(content_tag(:thead) do
            concat(content_tag(:tbody) do
              log.delivery_attempts.list.each do |o|
                concat(content_tag(:tr) do
                  keys.each do |k|
                    concat(content_tag(:td, o[k].is_a?(Time) ? o[k].in_time_zone.strftime("%Y-%m-%d %H:%M") : o[k].to_s.truncate(150)))
                  end
                end)
              end
            end)
          end)
        end
      end

      def display_clicks_icon_for log
        content_tag(:span, class: "label label-info") do
          concat(icon('hand-o-up'))
          concat("&nbsp;".html_safe)
          concat(log.clicks.list.count)
        end if log.clicks.list.count > 0
      end

      def display_opens_icon_for log
        content_tag(:span, class: "label label-info") do
          concat(icon(:eye))
          concat("&nbsp;".html_safe)
          concat(log.opens.list.count)
        end if log.opens.list.count > 0
      end

      def display_delivery_attempts_icon_for log
        content_tag(:span, class: "label label-warning") do
          concat(icon(:exclamation))
          concat("&nbsp;".html_safe)
          concat(log.delivery_attempts.list.count)
        end if log.delivery_attempts.list.count > 0
      end

      def display_log_status log, for_modal = false
        case log.status
        when :clicked
          content_tag(:span, icon('hand-o-up', tw("logs.status.clicked")), class: "log-status text-clicked").concat(display_clicks_icon_for(log)).concat(display_opens_icon_for(log)).concat(display_delivery_attempts_icon_for(log))
        when :opened
          content_tag(:span, icon(:eye, tw("logs.status.opened")), class: "log-status text-opened").concat(display_opens_icon_for(log)).concat(display_delivery_attempts_icon_for(log))
        when :delivered
          content_tag(:span, icon(:check, tw("logs.status.delivered")), class: "log-status text-success").concat(display_delivery_attempts_icon_for(log))
        when :skipped
          content_tag(:span, icon(:times, tw("logs.status.skipped")), class: "log-status text-warning").concat(display_delivery_attempts_icon_for(log))
        when :error
          if for_modal
            content_tag(:span, class: "log-status text-danger") do
              concat(icon(:exclamation, tw("logs.status.error")))
              concat(content_tag(:a, icon(:refresh, tw("label_retry")), href: retry_log_path(log), data: {method: :post, remote: true}, class: "btn-retry"))
            end
          else
            content_tag(:span, icon(:exclamation, tw("logs.status.error")), class: "log-status text-danger").concat(display_delivery_attempts_icon_for(log))
          end
        when :scheduled
          content_tag(:span, icon(:"clock-o", tw("logs.status.scheduled")), class: "log-status text-muted")
        end
      end

      def display_log_skip_reason skip_reason
        tw("logs.skip_reason.#{skip_reason}") if skip_reason
      end

      def render_preview
        render_preview_nav.concat(render_preview_content)
      end

      def render_preview_nav
        content_tag(:ul, class: "nav nav-tabs") do
          concat(content_tag(:li, class: "active") do
            content_tag(:a, "HTML", href: "#preview-html", role: "tab", data: {toggle: :tab})
          end) if @preview.html?

          concat(content_tag(:li, class: @preview.html? ? "" : "active") do
            content_tag(:a, "PLAIN", href: "#preview-plain", role: "tab", data: {toggle: :tab})
          end) if @preview.plain?

          concat(content_tag(:li, class: @preview.html? || @preview.plain? ? "" : "active") do
            content_tag(:a, "RAW", href: "#preview-raw", role: "tab", data: {toggle: :tab})
          end)
        end
      end

      def render_preview_content
        content_tag(:div, class: "tab-content") do
          concat(content_tag(:div, id: "preview-html", class: "tab-pane fade in active") do
            content_tag(:iframe, '', src: defined?(@log) ? preview_html_template_log_path(@log) : preview_html_template_for_path(@item, @e), width: "100%", height: 400, frameborder: 0)
          end) if @preview.html?

          concat(content_tag(:div, id: "preview-plain", class: "tab-pane fade #{'active in' unless @preview.html?}") do
            content_tag(:pre, @preview.plain)
          end) if @preview.plain?

          concat(content_tag(:div, id: "preview-raw", class: "tab-pane fade #{'active in' unless @preview.html? || @preview.plain?}") do
            content_tag(:pre, defined?(@log) && @log.delivered? ? @log.data[:content] : @preview.mail)
          end)
        end
      end
    end
  end
end
