# require 'xcode_assets_gen/version'
require 'xcode_assets_gen/'

icon_gen =  XcodeAssetsGen::IconGen.new
icon_gen.icon_set_list = ['ipad-ios7+', 'iphone-ios7+']
icon_gen.save_path = "~/Documents/Asset"
icon_gen.o_icon_path = "~/Documents/icon.png"