require 'xcode_assets_gen/version'
require 'xcode_assets_gen/icon_gen'
require 'xcode_assets_gen/launch_image_gen'
require 'xcode_assets_gen/top_contents_json_gen'

require 'fileutils'
require 'slop'

module XcodeAssetsGen
  class CLI
      # set up defaults in its own method
    def cli_flags
      options = Slop::Options.new
      pwd = Dir.pwd
      options.banner =  "usage: tubes [options] ..."
      options.string    "-i", "--icon", "Set icon path, default is ./icon.png", default: File.join(pwd, "icon.png")
      options.string    "-l", "--launch_image_path", "Set launch image path, default is current path", default: pwd
      options.string    "-o", "--output", "Set output file path, default is ./Assets.xcassets", default: File.join(pwd, "Assets.xcassets")
      options.string    "-s", "--icon_set_list", "Set icon set list, default: ['ipad-ios7+', 'iphone-ios7+']", default: ['ipad-ios7+', 'iphone-ios7+']
      options
    end

    def parse_arguments(command_line_options, parser)
      begin
        # slop has the advantage over optparse that it can do strings and not just ARGV
        result = parser.parse command_line_options
        result.to_hash

      # Very important to not bury this begin/rescue logic in another method
      # otherwise it will be difficult to check to see if -h or --help was passed
      # in this case -h acts as an unknown option as long as we don't define it
      # in cli_flags.
      rescue Slop::UnknownOption
        # print help
        puts cli_flags
        exit
        # If, for your program, you can't exit here, then reraise Slop::UnknownOption
        # raise a custom exception, push the rescue up to main or track that "help was invoked"
      end
    end

    def main(command_line_options="")
      parser = Slop::Parser.new cli_flags
      arguments = parse_arguments(command_line_options, parser)

      # --ip is a boolean, it is set to false even if left off by slop
      icon_path = arguments.fetch(:icon)
      launch_image_path = arguments.fetch(:launch_image_path)
      output = arguments.fetch(:output)
      icon_set_list = arguments.fetch(:icon_set_list)

      XcodeAssetsGen::IconGen.new.gen_icons(icon_set_list, output, icon_path)
      XcodeAssetsGen::LaunchImageGen.new.gen_launch_images(output, launch_image_path)
      XcodeAssetsGen.gen_top_contents_json(output)
    end

  end
end