module Jekyll
  class Sitemap < Generator
    safe true
    priority :lowest

    def generate(site)
      pages = site.pages
      languages = site.config['languages']
      default_lang = site.config['default_lang']

      # generate only once
      return unless default_lang == site.active_lang

      sitemap = {}
      languages.each do |lang|
        lang = lang == default_lang ? '' : '/' + lang
        pages.each do |page|
          if sitemap.key?(page.name)
            sitemap[page.name] << lang + page.url
          else
            sitemap.store(page.name, [lang + page.url])
          end
        end
      end

      save sitemap
    end

    private
      def save(sitemap)
        File.open('sitemap.json', 'w') do |f|
          f.write(sitemap.to_json)
        end
      end
  end
end
