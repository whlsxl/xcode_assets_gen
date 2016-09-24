require "mini_magick"
require 'yaml'
require 'json'
require 'fileutils'

module XcodeAssetsGen
  class LaunchImageGen
    attr_accessor :assets_path, :launch_image_path

    def load_config
      return YAML.load_file(File.expand_path('../launch_image_size.yml', __FILE__))
    end

    def get_launch_items config, size
      config.flatten(1).select { |item| item["size"] == size }
    end

    def get_launch_items_with_set config, size, filename
      datas = []
      config.each do |items|
        for item in items
          if item["size"] == size
            datas += items.each { |item| item["data"]["filename"] = filename if item["size"] == size}
            break
          end
        end
      end
      datas
    end

    def set_launch_to_array datas, config, size, filename
      if (datas.select { |item| item["size"] == size }).count != 0
        datas.each { |item| item["data"]["filename"] = filename if item["size"] == size }
      else
        datas += get_launch_items_with_set(config, size, filename)
      end
      datas
    end

    def detect_launch_images assets_path, launch_image_path
      config = load_config
      datas = []
      launch_image_asset_path = File.join(assets_path, "LaunchImage.launchimage")
      Dir.glob(File.join(launch_image_path, "*.png")) do |file|
        image = MiniMagick::Image.open(file)
        size = "#{image.width}x#{image.height}"
        filename = "launch_image#{size}.png"
        if get_launch_items(config, size)
          FileUtils.cp(file, File.join(launch_image_asset_path, filename))
        end
        datas = set_launch_to_array(datas, config, size, filename)
      end
      content = datas.map { |item| item["data"] }
      File.open(File.join(launch_image_asset_path, "Contents.json"), "w") do |f|
        f.write(content.to_json)
      end
    end

  end
end
