# require "xcode_assets_gen/version"
require "mini_magick"
require 'yaml'
require 'json'
require 'fileutils'

module XcodeAssetsGen
  class IconGen
    @icon_set_list = []
    @config = []
    @assets_path = ""
    @o_icon_path = ""

    attr_accessor :icon_set_list, :assets_path, :o_icon_path

    def load_config
      return YAML.load_file(File.expand_path('../icons_size.yml', __FILE__))
    end

    def gen_top_contents_json
      content = {
        "info": {
          "version": 1,
          "author": "xcode"
        }
      }
      File.open(File.join(@assets_path, "Contents.json"), "w") do |f|
        f.write(content.to_json)
      end
    end

    def get_config_by_name name
      @config.detect { |config| config["name"] == name }
    end

    def gen_icons
      @config = load_config
      @icon_save_path = File.join(@assets_path, 'AppIcon.appiconset')
      FileUtils::mkdir_p @icon_save_path
      gen_top_contents_json

      images = []
      @icon_set_list.each { |icon_set|
        config = get_config_by_name(icon_set)
        if config != nil
          images += gen_icon_set(config)
        end
      }
      content = {
        "images": images,
        "info": {
          "version": 1,
          "author": "xcode"
        }
      }
      File.open(File.join(@icon_save_path, "Contents.json"), "w") do |f|
        f.write(content.to_json)
      end
    end

    def get_icon_size icon
      size = icon["size"].split('x').first.to_f
      scale = icon["scale"].split('x').first.to_f
      (size * scale).to_i
    end

    def gen_icon_set icon_set
      images = []
      icon_set["icons"].each { |icon|
        image = MiniMagick::Image.open(@o_icon_path)
        size = get_icon_size icon
        image.resize "#{size}x#{size}"
        image.format "png"
        image.write File.join(@icon_save_path, "icon#{size}x#{size}.png")
        icon['idiom'] = icon_set["idiom"]
        icon['filename'] = "icon#{size}x#{size}.png"
        images.push(icon)
      }
      # return content file json
      return images

    end

  end
end

module XcodeAssetsGen
  class LaunchImageGen

  end
end

icon_gen =  XcodeAssetsGen::IconGen.new
icon_gen.icon_set_list = ['ipad-ios7+', 'iphone-ios7+']
icon_gen.assets_path = "/Users/whl/Documents/Assets.xcassets/"
icon_gen.o_icon_path = "/Users/whl/Documents/icon.png"
icon_gen.gen_icons
