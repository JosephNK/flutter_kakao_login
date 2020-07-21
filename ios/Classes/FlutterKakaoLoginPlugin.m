#import "FlutterKakaoLoginPlugin.h"
#if __has_include(<flutter_kakao_login/flutter_kakao_login-Swift.h>)
#import <flutter_kakao_login/flutter_kakao_login-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_kakao_login-Swift.h"
#endif

@implementation FlutterKakaoLoginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterKakaoLoginPlugin registerWithRegistrar:registrar];
}
@end
