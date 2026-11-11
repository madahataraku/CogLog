Pod::Spec.new do |s|
  s.name             = 'infra_on_device_llm_mobile'
  s.version          = '0.1.0'
  s.summary          = 'On-device LLM for CogLog using OS models only.'
  s.description      = 'Apple Foundation Models on iOS and Gemini Nano on Android.'
  s.homepage         = 'https://github.com/madahataraku/CogLog'
  s.license          = { :type => 'MIT' }
  s.author           = { 'CogLog' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{swift}'
  s.dependency 'Flutter'
  s.platform = :ios, '16.4'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.weak_frameworks = 'FoundationModels'
  s.resource_bundles = { 'infra_on_device_llm_mobile_privacy' => ['Classes/PrivacyInfo.xcprivacy'] }
end
