Pod::Spec.new do |s|
  s.name             = 'PassageSwift'
  s.module_name      = 'Passage'
  s.version          = ENV['LIB_VERSION'] || '1.0.1'
  s.summary          = 'Passkey Complete for Apple Platforms - Go completely passwordless with a standalone auth solution in your Swift apps with Passage by 1Password'
  s.homepage         = 'http://docs.passage.id/complete'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Passage by 1Password' => 'support@passage.id' }
  s.source           = { :git => 'https://github.com/passageidentity/passage-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = "14.0"
  # s.osx.deployment_target = "12.0"
  # s.tvos.deployment_target = "14.0"
  # s.watchos.deployment_target = "7.0"
  # s.visionos.deployment_target = "1.0"
  s.swift_version = '5.0'
  s.source_files = 'Sources/Passage/**/*'
  s.dependency 'AnyCodable-FlightSchool', '0.6.1'
end
