#
# Be sure to run `pod lib lint TRectDetector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TRectDetector'
  s.version          = '0.1.0'
  s.summary          = '相机矩形识别+自定义裁剪矫正'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
直接显示controller就可以使用
                       DESC

  s.homepage         = 'https://github.com/RainyMask'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1370254410@qq.com' => 'daitao@chaorey.com' }
  s.source           = { :git => 'https://github.com/RainyMask/TRectDetector.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TRectDetector/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TRectDetector' => ['TRectDetector/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

    s.dependency "Masonry"
    s.dependency "GPUImage"
    s.dependency "TZImagePickerController"
    s.dependency "MBProgressHUD"

end
