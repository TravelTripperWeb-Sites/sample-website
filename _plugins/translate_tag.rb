require 'i18n'

module Jekyll
  class TranslateTag < Liquid::Tag
    def initialize(tag_name, token, *args)
      super
      load_translations
      @token = token.strip
    end

    def render(context)
      site = context.registers[:site]
      I18n.locale = site.active_lang || site.default_lang || :en
      I18n.available_locales = site.languages || [site.default_lang || :en]

      I18n.t @token
    end

    private

      def load_translations
        unless I18n::backend.instance_variable_get(:@translations)
          I18n.backend.load_translations Dir[File.join(File.dirname(__FILE__), '../_locales/*.yml')]
        end
      end
  end
end

Liquid::Template.register_tag('t', Jekyll::TranslateTag)
