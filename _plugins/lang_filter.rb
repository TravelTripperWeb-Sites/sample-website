module Jekyll
  module LangFilter
    def lang(input, locale)
#      site = @context.registers[:site]
      config = Jekyll.configuration({})
      baseurl = config['baseurl']
      languages = config['languages'] || ['en']
      default_locale = config['default_lang'] || 'en'

      input.gsub! %r{#{baseurl}/(#{languages.join('|')})/}, "/" # remove any locales from url
      input = "/#{locale}" + input unless locale == default_locale # add locale unless default

      baseurl + input
    end
  end
end

Liquid::Template.register_filter(Jekyll::LangFilter)
