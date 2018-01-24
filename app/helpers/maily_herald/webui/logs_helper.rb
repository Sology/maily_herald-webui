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

      def display_log_status log, for_modal = false
        case log.status
        when :delivered
          content_tag(:span, icon(:check, tw("logs.status.delivered")), class: "text-success")
        when :skipped
          content_tag(:span, icon(:times, tw("logs.status.skipped")), class: "text-warning")
        when :error
          if for_modal
            content_tag(:span, class: "text-danger") do
              concat(icon(:exclamation, tw("logs.status.error")))
              concat(content_tag(:a, icon(:refresh, tw("label_retry")), href: retry_log_path(log), data: {method: :post, remote: true}, class: "btn-retry"))
            end
          else
            content_tag(:span, icon(:exclamation, tw("logs.status.error")), class: "text-danger")
          end
        when :scheduled
          content_tag(:span, icon(:"clock-o", tw("logs.status.scheduled")), class: "text-muted")
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
