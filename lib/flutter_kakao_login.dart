import 'dart:async';

import 'package:flutter/services.dart';

class FlutterKakaoLogin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_kakao_login');

  Future<bool> get isLoggedIn async => await currentToken != null;

  /// Init
  /// 카카오 sdk 사용 전 init 코드를 호출해야 합니다.
  Future<void> init(String appKey) {
    return _channel.invokeMethod('init', appKey);
  }

  /// Get Current Token Method
  /// 현재 저장된 Token 정보를 가져옵니다.
  Future<KakaoToken> get currentToken async {
    final Map<String, dynamic> json =
        await _channel.invokeMapMethod<String, dynamic>('getCurrentToken');
    return KakaoToken.fromJson(json);
  }

  /// HashKey Method ( android only )
  Future<String> get hashKey async {
    final String hashKey = await _channel.invokeMethod('hashKey');
    return hashKey;
  }

  // Get UserMe Method
  Future<KakaoLoginResult> getUserMe() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getUserMe');
      return _delayedToResult(KakaoLoginResult._(result));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Login Method
  Future<KakaoToken> logIn() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('logIn');
      return _delayedToResult(KakaoToken.fromJson(result));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Logout Method
  Future<KakaoLoginResult> logOut() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('logOut');
      return _delayedToResult(KakaoLoginResult._(result));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Unlink Method
  Future<KakaoLoginResult> unlink() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('unlink');
      return _delayedToResult(KakaoLoginResult._(result));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Helper Delayed Method
  Future<T> _delayedToResult<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }
}

// Login Result Status
enum KakaoLoginStatus { loggedIn, loggedOut, unlinked }

// Login Result Class
class KakaoLoginResult {
  final KakaoLoginStatus status;
  final KakaoAccountResult account;

  KakaoLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        account = KakaoAccountResult._(map);

  static KakaoLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return KakaoLoginStatus.loggedIn;
      case 'loggedOut':
        return KakaoLoginStatus.loggedOut;
      case 'unlinked':
        return KakaoLoginStatus.unlinked;
    }

    throw StateError('Invalid status: $status');
  }
}

// Account Class
class KakaoAccountResult {
  final String userID;
  final String userEmail;
  final String userPhoneNumber;
  final String userDisplayID;
  final String userNickname;
  final String userGender;
  final String userAgeRange;
  final String userBirthyear;
  final String userBirthday;
  final String userProfileImagePath;
  final String userThumbnailImagePath;

  KakaoAccountResult._(Map<String, dynamic> map)
      : userID = map['userID'],
        userEmail = map['userEmail'],
        userPhoneNumber = map['userPhoneNumber'],
        userDisplayID = map['userDisplayID'],
        userNickname = map['userNickname'],
        userGender = map['userGender'],
        userAgeRange = map['userAgeRange'],
        userBirthyear = map['userBirthyear'],
        userBirthday = map['userBirthday'],
        userProfileImagePath = map['userProfileImagePath'],
        userThumbnailImagePath = map['userThumbnailImagePath'];
}

/// 카카오 로그인을 통해 발급 받은 토큰.
class KakaoToken {
  /// API 인증에 사용하는 엑세스 토큰.
  final String accessToken;

  /// 엑세스 토큰 만료 시각.
  final DateTime accessTokenExpiresAt;

  /// 엑세스 토큰을 갱신하는데 사용하는 리프레시 토큰.
  final String refreshToken;

  /// 리프레시 토큰 만료 시각. Nullable
  final DateTime refreshTokenExpiresAt;

  /// 이 토큰에 부여된 scope 목록.
  final List<String> scopes;

  KakaoToken(this.accessToken, this.accessTokenExpiresAt, this.refreshToken,
      [this.refreshTokenExpiresAt, this.scopes]);

  factory KakaoToken.fromJson(Map<String, dynamic> json) => KakaoToken(
        json['accessToken'],
        DateTime.fromMillisecondsSinceEpoch(
            json['accessTokenExpiresAt'] as int),
        json['refreshToken'],
        json['refreshTokenExpiresAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['refreshTokenExpiresAt'])
            : null,
        List<String>.from(json['scopes'] ?? <String>[]),
      );
}
