module Jekyll
  class CmsRegionTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @filename = text.strip + '.json'
    end

    def render(context)
      root_path = context.registers[:site].source
      page_folder = context['page']['path']
      region_data_path = File.join(root_path, '_data', '_regions', page_folder)
      include_data_path = File.join(root_path, '_includes', '_regions')

      region_items = read_data_json_from(region_data_path)
      raise "Array is expected in #{@ilename}, but #{region_items.class.to_s} found" unless region_items.instance_of? Array

      wrap('div', 'class' => 'tt-region', 'data-region' => File.join(page_folder, @filename)) do
        region_items.each_with_index.map do |ped, index|
          include(include_data_path, context, index, ped)
        end.join
      end
    rescue Exception => error
      return 'Error: ' + error.message
    end

    private

    def include(include_data_path, context, index, ped)
      liquid = Liquid::Template.parse(read_include(include_data_path, ped['_template']))

      context['include'] = {'instance' => ped}
      wrap('div', 'class' => 'tt-region_ped', 'data-ped-index' => index, 'data-ped-type' => ped['_template']) do
        liquid.render(context)
      end
    end

    def read_include(include_data_path, filename)
      template_path = File.join(include_data_path, filename)
      raise "Can't find template file #{template_path}" unless File.exists?(template_path)
      File.open(template_path, 'r') do |file|
        file.read
      end
    end

    def read_data_json_from(region_data_path)
      path = File.join(region_data_path, @filename)
      if File.exists?(path)
        File.open(path, 'r') do |file|
          JSON.parse(file.read)
        end
      else
        []
      end
    end

    def wrap(tag, options)
      attrs = options.map { |k,v| "#{k}='#{v}'"}.join(' ')
      "<#{tag} #{attrs}>#{yield}</#{tag}>"
    end

  end
end

Liquid::Template.register_tag('region', Jekyll::CmsRegionTag)
