require 'json'

module Jekyll
  class DataReader
    alias_method :read_orig, :read

    def read(dir)
      read_orig(dir)
      @locale = @site.active_lang
      @default_locale = @site.default_lang

      @content = assign_associations(translate_data(@content))
    end

    private

      # TODO refactor a lot :)

      def translate_data(content)
        map_content(content) do |key, value|
          if key.end_with?('_localized') && value.is_a?(Hash)
            [key.gsub('_localized', ''), value[@locale] || value[@default_locale]]
          end
        end
      end

      def assign_associations(content)
        map_content(content) do |key, value|
          if key.end_with?('_id') && value.is_a?(Fixnum)
            k = key.gsub('_id', '')
            [k, content[k + 's'].detect{|item| item['id'] == value }] # TODO correct pluralize (may be use activesupport)
          end
        end
      end

      def map_content(content, &block)
        case content
        when Hash
          {}.tap do |h|
            content.each do |key, value|
              k, v = yield(key, value)

              if k.nil? & v.nil?
                h[key] = map_content(value, &block)
              else
                h[k] = v
              end
            end
          end
        when Array
          content.map{|value| map_content(value, &block) }
        else
          content
        end
      end
  end
end

