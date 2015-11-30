require 'json'

module Jekyll
  class DataReader
    alias_method :read_orig, :read

    def read(dir)
      read_orig(dir)
      @locale = @site.active_lang
      @default_locale = @site.default_lang

      @content = translate_data(@content)
    end

    private
      def translate_data(content)
        case content
        when Hash
          {}.tap do |h|
            content.each do |key, value|
              case value
              when Hash
                if key.end_with?('_localized')
                  h[key.gsub('_localized', '')] = value[@locale] || value[@default_locale]
                else
                  h[key] = translate_data(value)
                end
              else
                h[key] = translate_data(value)
              end
            end
          end
        when Array
          content.map{|value| translate_data(value) }
        else
          content
        end
      end
  end
end

