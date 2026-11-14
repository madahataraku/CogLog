Pod::Spec.new do |s|
  s.name             = 'infra_meter_reading_mobile'
  s.version          = '0.1.0'
  s.summary          = 'Meter panel OCR for CogLog on iOS via Vision.'
  s.description      = 'Apple Vision text recognition for meter panel photos.'
  s.homepage         = 'https://github.com/madahataraku/CogLog'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'CogLog' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{swift}'
  s.dependency 'Flutter'
  s.platform = :ios, '16.4'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.frameworks = 'Vision', 'UIKit', 'CoreML'
  # Core ML 七セグモデルは macOS で tool/seven_segment から生成する。
  # 未配置のまま s.resources に書くと pod install が壊れるため、存在時のみ同梱する。
  mlpackage = File.join(__dir__, 'Resources', 'SevenSegment192.mlpackage')
  if File.exist?(mlpackage)
    s.resources = ['Resources/SevenSegment192.mlpackage']
  end
  s.resource_bundles = { 'infra_meter_reading_mobile_privacy' => ['Classes/PrivacyInfo.xcprivacy'] }
end
