require 'json'
require 'fileutils'

module XcodeAssetsGen
  def self.gen_top_contents_json assets_path
    puts Rainbow("Start generate Top Contents.json").bright
    content = {
      "info": {
        "version": 1,
        "author": "xcode"
      }
    }
    File.open(File.join(assets_path, "Contents.json"), "w") do |f|
      f.write(content.to_json)
    end
    puts Rainbow("Finish generate Top Contents.json").green
  end
end