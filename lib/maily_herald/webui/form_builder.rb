module MailyHerald
  module Webui
    class FormBuilder < ActionView::Helpers::FormBuilder
      FIELD_HELPERS = %w{text_field text_area}

      attr_reader :layout, :label_col, :control_col, :has_error, :inline_errors, :acts_like_form_tag

      delegate :content_tag, :capture, :concat, :t, :tw, to: :@template

      def initialize(object_name, object, template, options, proc = nil)
        @layout = options[:layout]
        @label_col = options[:label_col] || default_label_col
        @control_col = options[:control_col] || default_control_col
        @inline_errors = options[:inline_errors] != false
        @help_scope = options[:help_scope]

        if Rails::VERSION::MAJOR >= 4.2
          super
        else
          super object_name, object, template, options
        end
      end

      def prepend_and_append_input(options, &block)
        options = options.extract!(:prepend, :append)
        input = capture(&block)
        input = content_tag(:span, options[:prepend], class: options[:prepend].include?("button") ? "input-group-btn" : "input-group-addon") + input if options[:prepend]
        input << content_tag(:span, options[:append], class: options[:append].include?("button") ? "input-group-btn" : "input-group-addon") if options[:append]
        input = content_tag(:div, input, class: "input-group") unless options.empty?
        input
      end

      FIELD_HELPERS.each do |method_name|
        with_method_name = "#{method_name}_with_maily"
        without_method_name = "#{method_name}_without_maily"
        define_method(with_method_name) do |name, options = {}|
          form_group_builder(name, options) do
            prepend_and_append_input(options) do
              send(without_method_name, name, options)
            end
          end
        end
        alias_method_chain method_name, :maily
      end


      def select_with_maily(method, choices, options = {}, html_options = {})
        form_group_builder(method, options, html_options) do
          content_tag(:span, class: ["select-wrap", ("has-error" if has_error?(method))]) do
            select_without_maily(method, choices, options, html_options)
          end
        end
      end
      alias_method_chain :select, :maily

      def check_box_with_maily(method, options = {}, checked_value = "1", unchecked_value = "0")
        form_group_builder(method, options.merge(hide_label: true)) do
          content_tag(:div, class: "checkbox") do
            label method do
              concat(content_tag(:span, check_box_without_maily(method, options, checked_value, unchecked_value), class: "checkbox-wrap"))
              concat(object.class.human_attribute_name(method))
            end
          end
        end
      end
      alias_method_chain :check_box, :maily

      def radio_button_with_maily(method, options = {}, checked_value = "1", unchecked_value = "0")
        form_group_builder(method, options.merge(hide_label: true)) do
          content_tag(:div, class: "radio-wrap") do
            label method do
              concat(content_tag(:span, check_box_without_maily(method, options, checked_value, unchecked_value), class: "radio-btn"))
              concat(object.class.human_attribute_name(method))
            end
          end
        end
      end
      alias_method_chain :radio_button, :maily

      def maily_context_select(options = {}, html_options = {})
        choices = MailyHerald.contexts.values.collect do |context|
          [@template.friendly_name(context), context.name]
        end
        select_with_maily :context_name, choices, options, html_options
      end

      def maily_mailer_select(options = {}, html_options = {})
        choices = ObjectSpace.each_object(Class).select { |klass| klass < ActionMailer::Base }.collect do |mailer|
          if mailer.name == "MailyHerald::Mailer"
            ["Generic Mailer", "generic"]
          else
            [mailer.name, mailer.name]
          end
        end
        select_with_maily :mailer_name, choices, options, html_options
      end

      def maily_list_select(options = {}, html_options = {})
        choices = MailyHerald::List.all.collect do |list|
          [@template.friendly_name(list), list.name]
        end
        select_with_maily :list, choices, options.merge(prompt: tw("commons.please_select")), {autocomplete: "off"}.merge(html_options)
      end

      def maily_from_field options = {}, html_options = {}
        form_group_builder(:from, options.merge(wrapper_class: "mailing-from")) do
          radio1 = content_tag(:label, content_tag(:span, @template.radio_button_tag(:mailing_from, "default", !object.from.present?), class: "radio-btn") + @template.tw("mailings.from.default", email: object.mailer.default[:from]), class: "radio")
          radio2 = content_tag(:label, content_tag(:span, @template.radio_button_tag(:mailing_from, "specify", object.from.present?), class: "radio-btn") + tw("mailings.from.specify"), class: "radio")

          field = prepend_and_append_input(options) do
            text_field_without_maily(:from, {class: "form-control", placeholder: tw("mailings.placeholders.from")})
          end

          concat(content_tag(:p, radio1 + radio2)).concat(field)
        end
      end

      def maily_start_at_field options = {}, html_options = {}
        form_group_builder(:start_at, options.merge(wrapper_class: "dispatch-start-at")) do
          radio1 = content_tag(:label, content_tag(:span, @template.radio_button_tag(:mailing_from, "absolute", !object.from.present?), class: "radio-btn") + tw("mailings.start_at.absolute"), class: "radio")
          radio2 = content_tag(:label, content_tag(:span, @template.radio_button_tag(:mailing_from, "relative", object.from.present?), class: "radio-btn") + tw("mailings.start_at.relative"), class: "radio")
          calendar_btn = content_tag(:button, @template.icon(:calendar), class: "btn btn-default", type: "button")
          list_btn = @template.link_to_context_attributes_overview(object.list, class: "btn btn-default")

          field = prepend_and_append_input({append: calendar_btn + list_btn}) do
            text_field_without_maily(:start_at, {class: "form-control", placeholder: tw("mailings.placeholders.start_at")})
          end

          #concat(content_tag(:p, radio1 + radio2)).concat(field)
          field
        end
      end

      def maily_period_field options = {}, html_options = {}
        text_field :period_in_days, help: true, append: tw("mailings.help.period_unit"), placeholder: tw("mailings.placeholders.period")
      end

      def maily_absolute_delay_field options = {}, html_options = {}
        text_field :absolute_delay_in_days, help: true, append: tw("mailings.help.absolute_delay_unit"), placeholder: tw("mailings.placeholders.absolute_delay")
      end

      def form_group(*args, &block)
        options = args.extract_options!
        name = args.first

        options[:class] = ["form-group", options[:class]].compact.join(' ')
        options[:class] << " #{error_class}" if has_error?(name)
        options[:class] << " #{feedback_class}" if options[:icon]

        content_tag(:div, options.except(:id, :label, :help, :icon, :label_col, :control_col, :layout)) do
          label   = generate_label(options[:id], name, options[:label], options[:label_col], options[:layout], options[:help]) if options[:label]
          control = capture(&block).to_s
          control.concat(generate_help(name, options[:help]).to_s)
          #control.concat(generate_help(options[:help].is_a?(TrueClass) ? name : options[:help])) if options[:help]
          control.concat(generate_icon(options[:icon])) if options[:icon]

          if get_group_layout(options[:layout]) == :horizontal
            control_class = (options[:control_col] || control_col)

            unless options[:label]
              control_offset = offset_col(/([0-9]+)$/.match(options[:label_col] || default_label_col))
              control_class.concat(" #{control_offset}")
            end
            control = content_tag(:div, control, class: control_class)
          end

          concat(label).concat(control)
        end
      end

      def buttons *bs
        form_group do
          bs.each do |button|
            if button.is_a?(Array)
              label = button.last
              button = button.first
            end
            if button.is_a?(Symbol)
              case button
              when :submit
                concat(content_tag(:button, label || tw("commons.submit"), :class => "btn btn-webui", :type => "submit"))
              when :create
                concat(content_tag(:button, label || tw("commons.create"), :class => "btn btn-webui", :type => "submit", :name => "submit"))
              when :save
                concat(content_tag(:button, label || tw("commons.save"), :class => "btn btn-webui", :type => "submit", :name => "submit"))
              when :save_continue
                concat(content_tag(:button, label || tw("commons.save_continue"), :class => "btn btn-webui", :type => "submit", :name => "submit_continue"))
              when :cancel
                concat(content_tag(:button, label || tw("commons.cancel"), :class => "btn btn-webui-alternative cancel"))
              end
            else
              concat(content_tag(:button, button[:text], :class => button[:class], :type => button[:type]))
            end
            concat(" ")
          end
        end
      end

      private

      def form_group_builder(method, options, html_options = nil)
        options.symbolize_keys!
        html_options.symbolize_keys! if html_options

        # Add control_class; allow it to be overridden by :control_class option
        css_options = html_options || options
        control_classes = css_options.delete(:control_class) { control_class }
        css_options[:class] = [control_classes, css_options[:class]].compact.join(" ")

        label = options.delete(:label)
        label_class = hide_class if options.delete(:hide_label)
        wrapper_class = options.delete(:wrapper_class)
        help = options.delete(:help)
        icon = options.delete(:icon)
        label_col = options.delete(:label_col)
        control_col = options.delete(:control_col)
        layout = get_group_layout(options.delete(:layout))

        form_group(method, id: options[:id], label: { text: label, class: label_class }, help: help, icon: icon, label_col: label_col, control_col: control_col, layout: layout, class: wrapper_class) do
          yield
        end
      end

      def horizontal?
        layout == :horizontal
      end

      def get_group_layout(group_layout)
        group_layout || layout
      end

      def default_label_col
        "col-sm-2"
      end
      def offset_col(offset)
        "col-sm-offset-#{offset}"
      end
      def default_control_col
        "col-sm-10"
      end
      def hide_class
        "sr-only" # still accessible for screen readers
      end
      def control_class
        "form-control"
      end
      def label_class
        "control-label"
      end
      def error_class
        "has-error"
      end
      def feedback_class
        "has-feedback"
      end

      def has_error?(name)
        object.respond_to?(:errors) && !(name.nil? || object.errors[name].empty? || object.errors[name.to_s.chomp("_id").to_sym].empty?)
      end

      def generate_label(id, name, options, custom_label_col, group_layout, help)
        options[:for] = id if acts_like_form_tag
        classes = [options[:class], label_class]
        classes << (custom_label_col || label_col) if get_group_layout(group_layout) == :horizontal
        options[:class] = classes.compact.join(" ")

        text = options[:text] || object.class.human_attribute_name(name)
        text += " " + generate_help_icon(help.is_a?(TrueClass) ? name : help) if help

        label(name, text.html_safe, options.except(:text))
      end

      def generate_help_icon(help)
        @template.display_help_icon help, scope: @help_scope, placement: "top"
      end

      def generate_help(name, help_text)
        help_text = object.errors[name].join(", ") if has_error?(name) && inline_errors
        return if help_text === false

        help_text ||= I18n.t(name, scope: "activerecord.help.#{object.class.to_s.downcase}", default: '')
        content_tag(:span, help_text, class: 'help-block') if help_text.present? && help_text.is_a?(String)
      end

      def generate_icon(icon)
        content_tag(:span, "", class: "glyphicon glyphicon-#{icon} form-control-feedback")
      end
    end
  end
end
