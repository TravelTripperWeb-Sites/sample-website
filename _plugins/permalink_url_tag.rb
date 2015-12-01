module Jekyll
  class PermalinkUrlTag < Liquid::Tag
    def initialize(tag_name, token, *args)
      super
      @token = token.strip
    end

    def render(context)
      site = context.registers[:site]

      page = site.pages.detect do |p|
        page_url = Jekyll::URL.new({ template: p.template, placeholders: p.url_placeholders, permalink: nil }).to_s

        if @token.end_with?('/') && p.index? && page_url == @token
          true
        elsif !@token.end_with?('/')
          pathname = Pathname.new(page_url)
          dir = pathname.dirname.to_s
          base = pathname.basename('.*').to_s

          token_pathname = Pathname.new(@token)
          token_dir = token_pathname.dirname.to_s
          token_base = token_pathname.basename('.*').to_s

          @token == "#{dir}/#{base}" || "#{token_dir}/#{token_base}" == "#{dir}/#{base}"
        end
      end

      raise "permalink for '#{@token}' not found" if page.nil?

      permalink = page.permalink || @token
      permalink = "/#{site.active_lang}" + permalink unless site.active_lang == site.default_lang

      permalink
    end
  end
end

Liquid::Template.register_tag('permalink_url', Jekyll::PermalinkUrlTag)
