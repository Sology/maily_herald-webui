module MailyHerald
  module Webui
    class MenuManager
      module ControllerExtensions
        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods

          base.send :helper_method, :menu_manager, :set_menu_item, :current_menu_item
        end

        module ClassMethods
          protected

          def set_menu_item name
            before_filter do |controller|
              controller.send(:set_menu_item, name)
            end
          end
        end

        module InstanceMethods
          protected

          def set_menu_item name
            menu_manager.current_menu_item = name
          end

          def menu_manager 
            @menu_manager ||= MenuManager.new
          end

          def current_menu_item
            menu_manager.current_menu_item
          end
        end
      end

      attr_accessor :current_menu_item

      class << self
        @@items = nil

        def items
          @@items || setup
        end

        private

        def setup
          @items = [
            {:name => :dashboard, :title => :label_dashboard, :url => Proc.new{ root_path }},
            {:name => :lists, :title => :label_list_plural, :url => Proc.new{ lists_path }},
            {:name => :ad_hoc_mailings, :title => :label_ad_hoc_mailing_plural, :url => Proc.new{ ad_hoc_mailings_path }},
            {:name => :one_time_mailings, :title => :label_one_time_mailing_plural, :url => Proc.new{ one_time_mailings_path }},
            {:name => :periodical_mailings, :title => :label_periodical_mailing_plural, :url => Proc.new{ periodical_mailings_path }},
            {:name => :sequences, :title => :label_sequence_plural, :url => Proc.new{ sequences_path }},
          ]
        end
      end

      def items
        self.class.items
      end
    end
  end
end
