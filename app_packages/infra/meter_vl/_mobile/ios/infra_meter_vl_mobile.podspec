#
# LiteRTLM is distributed via Swift Package Manager.
# Flutter SPM: see infra_meter_vl_mobile/Package.swift (depends on LiteRTLM).
# CocoaPods fallback still compiles the same Sources; without LiteRTLM linked into
# the pod target, `#if canImport(LiteRTLM)` stays false until Flutter SPM is used.
# Runner.xcodeproj also links LiteRTLM for the app target.
#
Pod::Spec.new do |s|
  s.name             = 'infra_meter_vl_mobile'
  s.version          = '0.0.1'
  s.summary          = 'Meter VL reading via LiteRT-LM on iOS.'
  s.description      = 'Downloads LFM VL .litertlm and runs vision inference with LiteRT-LM.'
  s.homepage         = 'https://github.com/madahataraku/CogLog'
  s.license          = { :type => 'MIT' }
  s.author           = { 'CogLog' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'infra_meter_vl_mobile/Sources/infra_meter_vl_mobile/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '18.0'
  s.swift_version = '5.0'
  s.resource_bundles = {
    'infra_meter_vl_mobile_privacy' => [
      'infra_meter_vl_mobile/Sources/infra_meter_vl_mobile/PrivacyInfo.xcprivacy',
    ],
  }
end
