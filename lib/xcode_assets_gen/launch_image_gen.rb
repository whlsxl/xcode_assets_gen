require "mini_magick"
require 'yaml'
require 'json'
require 'fileutils'
require 'rainbow'

module XcodeAssetsGen
  class LaunchImageGen

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

    def gen_launch_images assets_path, launch_image_path
      puts Rainbow("Start generate launch images").bright
      config = load_config
      datas = []
      asset_launch_path = "LaunchImage.launchimage"
      launch_image_asset_path = File.join(assets_path, asset_launch_path)
      FileUtils::mkdir_p launch_image_asset_path
      Dir.glob(File.join(launch_image_path, "*.png")) do |file|
        image = MiniMagick::Image.open(file)
        size = "#{image.width}x#{image.height}"
        filename = "launch_image#{size}.png"

        if get_launch_items(config, size).count != 0
          FileUtils.cp(file, File.join(launch_image_asset_path, filename))
          datas = set_launch_to_array(datas, config, size, filename)
          puts Rainbow("Find #{File.basename(file)} size is #{size} CP TO #{asset_launch_path}/#{filename}").green
        else
          puts Rainbow("Find #{File.basename(file)} size is #{size} not a launch image").yellow
        end
      end
      content = {
        "images": datas.map { |item| item["data"] },
        "info": {
          "version": 1,
          "author": "xcode"
        }
      }
      File.open(File.join(launch_image_asset_path, "Contents.json"), "w") do |f|
        f.write(content.to_json)
      end
      puts Rainbow("Finish generate LaunchImages").green
    end

  end
end

# launch_gen =  XcodeAssetsGen::LaunchImageGen.new
# launch_gen.gen_launch_images("/Users/whl/Documents/Assets.xcassets/", "/Users/whl/Documents/ip_pro/rGuideMetro/rGuideMetro/Localized/whmtr")
