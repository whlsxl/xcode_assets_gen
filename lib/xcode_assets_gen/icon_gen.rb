# require "xcode_assets_gen/version"
require "mini_magick"
require 'yaml'
require 'json'
require 'fileutils'

module XcodeAssetsGen
  class IconGen

    attr_accessor :icon_set_list, :assets_path, :o_icon_path

    def load_config
      return YAML.load_file(File.expand_path('../icons_size.yml', __FILE__))
    end

    def get_config_by_name config, name
      config.detect { |config| config["name"] == name }
    end


    # icon_set_list is a list of icon set to generate, example: ['ipad-ios7+', 'iphone-ios7+']
    def gen_icons icon_set_list, assets_path, icon_path
      config = load_config
      icon_save_path = File.join(assets_path, 'AppIcon.appiconset')
      FileUtils::mkdir_p icon_save_path
      puts Rainbow("Start generate icons").bright

      images = []
      icon_set_list.each { |icon_set|
        puts Rainbow("Icon set #{icon_set}").cyan
        sets = get_config_by_name(config, icon_set)
        if sets != nil
          images += gen_icon_set(sets, icon_save_path, icon_path)
        else
          puts Rainbow("Error: No #{icon_set}").red
        end
      }
      content = {
        "images": images,
        "info": {
          "version": 1,
          "author": "xcode"
        }
      }
      File.open(File.join(icon_save_path, "Contents.json"), "w") do |f|
        f.write(content.to_json)
      end
      puts Rainbow("Finish generate icons").green
    end

    def get_icon_size icon
      size = icon["size"].split('x').first.to_f
      scale = icon["scale"].split('x').first.to_f
      (size * scale).to_i
    end

    def gen_icon_set icon_set, icon_save_path, icon_path
      images = []
      icon_set["icons"].each { |icon|
        image = MiniMagick::Image.open(icon_path)
        size = get_icon_size icon
        image.resize "#{size}x#{size}"
        image.format "png"
        icon_filename = "icon#{size}x#{size}.png"
        image.write File.join(icon_save_path, icon_filename)
        puts Rainbow("Generate #{icon_filename}").green
        icon['idiom'] = icon_set["idiom"]
        icon['filename'] = "icon#{size}x#{size}.png"
        images.push(icon)
      }
      # return content file json
      return images

    end

  end
end
