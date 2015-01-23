module MailyHerald
  module Webui
    module Breadcrumbs
      module ControllerExtensions
        def self.included(base)
          base.extend ClassMethods
          base.send :include, MailyHerald::Webui::Breadcrumbs::ControllerExtensions::InstanceMethods
        end

        module ClassMethods
          protected

          def add_breadcrumb name, url = nil, options = {}
            before_filter options do |controller|
              controller.send(:add_breadcrumb, name, url, options)
            end
          end
        end

        module InstanceMethods
          protected

          def self.included(base)
            base.extend ClassMethods
          end

          def add_breadcrumb name, url = nil, options = {}
            return unless name

            @breadcrumbs ||= []
            url = self.instance_eval(&url) if url.is_a?(Proc)
            url = eval(url.to_s) if url.to_s =~ /_path|_url|@/
            url = url.merge(:d => current_domain.id.to_s, :host => current_domain.hostname) if url && options[:localized]
            @breadcrumbs << {:name => name, :url => url, :intitle => options[:intitle], :intitle_only => options[:intitle_only]}
          end

          def disable_breadcrumbs 
            @breadcrumbs_disabled = true
          end
        end
      end

      module HelperExtensions
        def has_breadcrumbs?
          !@breadcrumbs_disabled && @breadcrumbs && !@breadcrumbs.empty?
        end
      end
    end
  end
end
