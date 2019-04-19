#
# Be sure to run `pod lib lint TRectDetector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TRectDetector'
  s.version          = '0.1.1'
  s.summary          = '相机矩形识别+自定义裁剪矫正'

  s.description      = <<-DESC
                        直接显示controller就可以使用
                       DESC

  s.homepage         = 'https://github.com/RainyMask'
  s.screenshots     = 'https://img-blog.csdnimg.cn/2019041909270463.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L05CX1Rva2Vu,size_16,color_FFFFFF,t_70', 'https://img-blog.csdnimg.cn/20190419092736452.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L05CX1Rva2Vu,size_16,color_FFFFFF,t_70'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1370254410@qq.com' => 'daitao@chaorey.com' }
  s.source           = { :git => 'https://github.com/RainyMask/TRectDetector.git', :tag => s.version.to_s }
  s.social_media_url = 'https://blog.csdn.net/NB_Token'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TRectDetector/Classes/**/*'
  
  s.resource_bundles = {
      'TRectDetector' => ['TRectDetector/Assets/*.png']
  }

  #s.resources = ['TRectDetector/Assets/resource/*.png']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency "Masonry"
  s.dependency "GPUImage"
  s.dependency "TZImagePickerController"
  s.dependency "MBProgressHUD"

end
