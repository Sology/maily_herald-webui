module MailyHerald
  module Webui
    module ApplicationHelper
      include MailyHerald::Webui::Breadcrumbs::HelperExtensions

      def render_main_menu
        content_tag(:ul, :class => "nav nav-main") do
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

      def link_to_context_attributes_overview list, options = {}
        link_to context_attributes_list_path(id: list, context: list.context_name), data: {toggle: "modal", target: "#modal-generic"}, class: ["link link-help", options[:class]] do 
          html = concat(icon(:list))
          html.concat(" ").concat(list.context_name) if options[:text]
        end if list.try(:context_name)
      end

      def render_context_attributes_info list
        render partial: "maily_herald/webui/shared/context_attributes", locals: {list: list}
      end

      def display_context_attributes attributes
        content_tag(:ul) do
          attributes.each do |k, v|
            if v.is_a?(Hash)
              concat(content_tag(:li) do
                concat(k)
                concat(display_context_attributes(v))
              end)
            else
              concat(content_tag(:li, k))
            end
          end
        end
      end

      def content_for_expert
        yield if settings.expert_mode
      end

      def work_mode_t mode
        t(mode, {scope: [:maily_herald, :webui, :work_modes]})
      end

      def setting_t setting
        t(setting, {scope: [:maily_herald, :webui, :settings]})
      end

      def tw(key, options = {})
        t(key, {scope: [:maily_herald, :webui]}.merge(options))
      end

      def friendly_name obj
        return unless obj
        obj.respond_to?(:title) && obj.title.present? ? obj.title : obj.try(:name)
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

      def boolean_icon value, options = {}
        options = {
          :style => :check,
          :text => :active,
        }.merge(options)

        i = case options[:style]
            when :check
              value ? "check-square-o" : "square-o"
            when :toggle
              value ? "toggle-on" : "toggle-off"
            end

        text = case options[:text]
               when :active
                 value ? tw("commons.active") : tw("commons.inactive")
               when :enabled
                 value ? tw("commons.enabled") : tw("commons.disabled")
               when :yes
                 value ? tw("commons.positive") : tw("commons.negative")
               end

        icon(i, text)
      end

      def display_help_icon title, options = {}
        link_to "#", class: "link link-help", data: {toggle: "tooltip", placement: options[:placement] || "right"}, title: (options[:scope] ? tw("#{options[:scope]}.help.#{title}") : t(".help.#{title}")) do
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

      def setting_switcher setting
        link_to(switch_setting_path(setting), method: :post) do
          concat(icon(settings.get(setting) ? "toggle-on" : "toggle-off"))
          concat("&nbsp;".html_safe)
          concat(setting_t(setting))
        end
      end

      def smart_listing_config_profile
        :maily_herald
      end

      def display_timestamp t
        if t && settings.friendly_timestamps?
          content_tag(:abbr, tw((t > Time.now) ? "commons.time_in" : "commons.time_ago", time: distance_of_time_in_words(t, Time.now)), title: t)
        else
          t
        end
      end
    end
  end
end
