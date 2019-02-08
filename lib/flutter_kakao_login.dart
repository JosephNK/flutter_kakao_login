import 'dart:async';

import 'package:flutter/services.dart';

class FlutterKakaoLogin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_kakao_login');

  Future<bool> get isLoggedIn async => await currentAccessToken != null;

  // Get Current AccessToken Method
  Future<KakaoAccessToken> get currentAccessToken async {
    final String accessToken = await _channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null) {
      return null;
    }
    return new KakaoAccessToken(accessToken);
  }

  // Get UserMe Method
  Future<KakaoLoginResult> getUserMe() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('getUserMe');

    return _delayedToResult(
        new KakaoLoginResult._(result.cast<String, dynamic>())
    );
  }

  // Login Method
  Future<KakaoLoginResult> logIn() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('logIn');

    return _delayedToResult(
        new KakaoLoginResult._(result.cast<String, dynamic>())
    );
  }

  // Logout Method
  Future<KakaoLoginResult> logOut() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('logOut');

    return _delayedToResult(
        new KakaoLoginResult._(result.cast<String, dynamic>())
    );
  }

  // Helper Delayed Method
  Future<T> _delayedToResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 500), () => result);
  }
}

// Login Result Status
enum KakaoLoginStatus {
  loggedIn,
  loggedOut,
  error
}

// Login Result Class
class KakaoLoginResult {
  final KakaoLoginStatus status;

  final KakaoAccountResult account; 

  final String errorMessage;

  KakaoLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        errorMessage = map['errorMessage'],
        account = new KakaoAccountResult._(map);

  static KakaoLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return KakaoLoginStatus.loggedIn;
      case 'loggedOut':
        return KakaoLoginStatus.loggedOut;
      case 'error':
        return KakaoLoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}

// Account Class
class KakaoAccountResult {
  final String userID;

  final String userEmail;

  final String userPhoneNumber;

  final String userDisplayID;

  final String userNickname;

  final String userProfileImagePath;

  final String userThumbnailImagePath;
  
  KakaoAccountResult._(Map<String, dynamic> map)
      : userID = map['userID'],
        userEmail = map['userEmail'],
        userPhoneNumber = map['userPhoneNumber'],
        userDisplayID = map['userDisplayID'],
        userNickname = map['userNickname'],
        userProfileImagePath = map['userProfileImagePath'],
        userThumbnailImagePath = map['userThumbnailImagePath'];
}

// AccessToken Class
class KakaoAccessToken {
  String token;

  KakaoAccessToken(this.token);
}