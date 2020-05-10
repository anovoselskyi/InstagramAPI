#
# Be sure to run `pod lib lint InstagramAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InstagramAPI'
  s.version          = '0.1.0'
  s.summary          = 'A InstagramAPI wrapper.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/anovoselskyi/InstagramAPI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrii Novoselskyi' => 'anovoselskyi@gmail.com' }
  s.source           = { :git => 'https://github.com/anovoselskyi/InstagramAPI.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/anovoselskyi'

  s.ios.deployment_target = '11.0'

  s.swift_versions = '5.1'

  s.source_files = 'InstagramAPI/Sources/**/*'
  
  # s.resource_bundles = {
  #   'InstagramAPI' => ['InstagramAPI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RxSwift', '~> 5.0'
end
