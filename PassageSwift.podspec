Pod::Spec.new do |s|
  s.name             = 'PassageSwift'
  s.module_name      = 'Passage'
  s.version          = ENV['LIB_VERSION'] || '1.0.1'
  s.summary          = 'Use Passage Authentication in your iOS application'
  s.homepage         = 'https://github.com/passageidentity/passage-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Passage Identity, Inc' => 'hello@passage.id' }
  s.source           = { :git => 'https://github.com/passageidentity/passage-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = "14.0"
  s.osx.deployment_target = "12.0"
  # s.tvos.deployment_target = "14.0"
  # s.watchos.deployment_target = "7.0"
  # s.visionos.deployment_target = "1.0"
  s.swift_version = '5.0'
  s.source_files = 'Sources/Passage/**/*'
  s.dependency 'AnyCodable-FlightSchool', '0.6.1'
end
