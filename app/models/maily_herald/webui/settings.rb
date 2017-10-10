module MailyHerald
  module Webui
    class Settings
      MAP = {
        expert_mode: {type: :boolean, default: false},
        show_skipped: {type: :boolean, default: false},
        friendly_timestamps: {type: :boolean, default: true},
      }.freeze

      def initialize cookies
        @cookies = cookies
      end

      def get setting
        return unless exists?(setting)

        v = @cookies[setting_key(setting)]
        case setting_type(setting)
        when :boolean
          return setting_default(setting) unless v
          return v == "1" ? true : false
        end
      end

      def set setting, value
        return unless exists?(setting)

        value = case setting_type(setting)
                when :boolean
                  value ? "1" : "0"
                end
        @cookies.permanent[setting_key(setting)] = value
      end

      def toggle setting
        return unless exists?(setting)

        if setting_type(setting) == :boolean
          v = get(setting)
          set(setting, !v)
        end
      end

      def exists? s
        MAP.keys.include?(s.to_sym)
      end

      def method_missing(m, *args, &block)  
        m =  m[0..(m.length-2)] if m[-1] == "?"
        if exists?(m)
          get(m)
        end
      end

      private

      def setting_key s
        "maily_settings_#{s}"
      end

      def setting_type s
        MAP[s.to_sym][:type]
      end

      def setting_default s
        MAP[s.to_sym][:default]
      end
    end
  end
end
