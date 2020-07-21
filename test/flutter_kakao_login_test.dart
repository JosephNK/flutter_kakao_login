import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter_kakao_login/flutter_kakao_login.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_kakao_login');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  //test('getPlatformVersion', () async {
  //  expect(await FlutterKakaoLogin.platformVersion, '42');
  //});
}
