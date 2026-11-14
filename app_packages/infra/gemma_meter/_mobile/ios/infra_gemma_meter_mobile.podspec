#
# LiteRTLM is distributed via Swift Package Manager, not CocoaPods.
# CocoaPods podspecs do not expose a stable `swift_package` DSL for Flutter
# plugins, so add the package in the app Xcode project / Podfile workflow:
#
#   https://github.com/google-ai-edge/LiteRT-LM  (from: "0.12.0")
#   Product: LiteRTLM
#
# Until LiteRTLM is linked, the plugin compiles with `#if canImport(LiteRTLM)`
# and reports availability as unavailable.
#
Pod::Spec.new do |s|
  s.name             = 'infra_gemma_meter_mobile'
  s.version          = '0.1.0'
  s.summary          = 'Gemma E2B meter reading via LiteRT-LM.'
  s.description      = 'Downloads Gemma E2B LiteRT-LM models and runs vision inference.'
  s.homepage         = 'https://github.com/madahataraku/CogLog'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'CogLog' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{swift}'
  s.dependency 'Flutter'
  s.platform = :ios, '16.4'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = { 'infra_gemma_meter_mobile_privacy' => ['Classes/PrivacyInfo.xcprivacy'] }
end
