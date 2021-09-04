#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_kakao_login.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_kakao_login'
  s.version          = '1.0.0'
  s.summary          = 'A new flutter_kakao_login plugin project.'
  s.description      = 'A new flutter_kakao_login plugin project description'
  s.homepage         = 'https://github.com/JosephNK/flutter_kakao_login'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'JosephNK' => 'nkw0608@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'KakaoSDKCommon', '~> 2.7.0'
  s.dependency 'KakaoSDKAuth', '~> 2.7.0'
  s.dependency 'KakaoSDKUser', '~> 2.7.0'
  s.static_framework = true
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
