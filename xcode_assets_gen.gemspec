# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcode_assets_gen/version'

Gem::Specification.new do |spec|
  spec.name          = "xcode_assets_gen"
  spec.version       = XcodeAssetsGen::VERSION
  spec.authors       = ["Wang Hailong"]
  spec.email         = ["whlsxl@gmail.com"]

  spec.summary       = %q{Generate icons and launch images Assets.xcassets file.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files bin lib *.md LICENSE`.split("\n")


  spec.bindir        = "bin"
  spec.executables   = ["xcode_assets_gen"]
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_magick", "~> 4.0"
  spec.add_dependency "slop", "~> 4.2.0"
  spec.add_dependency "rainbow", "~> 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

end
