#
# Be sure to run `pod lib lint DSExpandableHasTagLabel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DSExpandableHasTagLabel'
  s.version          = '0.1.0'
  s.summary          = "DSExpandableHashtagLabel is a simple UILabel subclass that shows a tappable link if the content doesn't fit the specified number of lines. If touched, the label will expand to show the entire content. Also, you will be notified when the user taps on any hashtag or any mentioned username."
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/dharmilShiyani/DSExpandableHasTagLabel'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dharmilShiyani' => 'dharmil.official@gmail.com' }
  s.source           = { :git => 'https://github.com/dharmilShiyani/DSExpandableHasTagLabel.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/dharmilShiyani'
  
  s.ios.deployment_target = '13.0'
  
  s.source_files = 'Classes/**/*.swift'
  
  s.swift_version = '5.0'
  
  s.platforms = {
    "ios": "13.0"
  }
  
  # s.resource_bundles = {
  #   'DSExpandableHasTagLabel' => ['DSExpandableHasTagLabel/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
