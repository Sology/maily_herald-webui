module MailyHerald
  module Webui
    module ApplicationHelper
      include MailyHerald::Webui::Breadcrumbs::HelperExtensions

      def render_main_menu
        content_tag(:ul, :class => "nav nav-main nav-justified") do
          menu_manager.items.each do |i|
            title = i[:title] || i[:name]
            title = tw(title) if title.is_a?(Symbol)

            url = i[:url]
            url = self.instance_eval(&url) if url.is_a?(Proc)

            classes = []
            classes << "active" if current_menu_item == i[:name]

            concat(content_tag(:li, :class => classes) do
              concat(link_to(title, url))
            end)
          end
        end
      end

      def render_breadcrumbs
        if has_breadcrumbs?
          content_tag(:ul, :class => "breadcrumb") do
            @breadcrumbs.each do |b|
              unless @breadcrumbs.last == b
                concat(content_tag(:li) do
                  concat(link_to(b[:name].is_a?(Symbol) ? tw(b[:name]) : b[:name], b[:url]))
                end)
              else
                concat(content_tag(:li, :class => "active") do
                  concat(b[:name].is_a?(Symbol) ? tw(b[:name]) : b[:name])
                end)
              end
            end
          end
        end
      end

      def content_for_expert
        yield if expert_mode?
      end

      def work_mode_t mode
        t(mode, {scope: [:maily_herald, :webui, :work_modes]})
      end

      def tw(key, options = {})
        t(key, {scope: [:maily_herald, :webui]}.merge(options))
      end

      def friendly_name obj
        return unless obj
        obj.title.present? ? obj.title : obj.name
      end

      def form_for(object, options = {}, &block)
        options.reverse_merge!({builder: MailyHerald::Webui::FormBuilder})
        layout = case options[:layout]
                 when :inline
                   "form-inline"
                 when :horizontal
                   "form-horizontal"
                 end
        if layout
          options[:html] ||= {}
          options[:html][:class] = [options[:html][:class], layout].compact.join(" ")
        end

        super(object, options, &block)
      end

      def icon(icon, text="", html_options={})
        content_class = "fa fa-#{icon}"
        content_class << " #{html_options[:class]}" if html_options.key?(:class)
        html_options[:class] = content_class

        html = content_tag(:i, nil, html_options)
        html << " #{text}" unless text.blank?
        html.html_safe
      end

      def boolean_icon value, style = :check
        case style
        when :check
          icon(value ? "check-square-o" : "check-o", value ? tw("commons.active") : tw("commons.inactive"))
        when :toggle
          icon(value ? "toggle-on" : "toggle-off", value ? tw("commons.enabled") : tw("commons.disabled"))
        end
      end

      def display_help_icon title
        link_to "#", class: "link link-help", data: {toggle: "tooltip", placement: "right"}, title: t(".help.#{title}")do
          icon(:question)
        end
      end

      def filter_box field_name = :filter
        content_tag(:div, class: "filter filter-search") do
          concat(text_field_tag(field_name, params[field_name], class: "search form-control", placeholder: "Search...", autocomplete: "off"))
          concat(button_tag(class: "btn", type: "submit") do
            icon(:search)
          end)
        end
      end
    end
  end
end
