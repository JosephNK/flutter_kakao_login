import 'dart:async';

import 'package:flutter/services.dart';

class FlutterKakaoLogin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_kakao_login');

  Future<bool> get isLoggedIn async => await currentAccessToken != null;

  // Get Current AccessToken Method
  Future<KakaoAccessToken> get currentAccessToken async {
    final String accessToken =
        await _channel.invokeMethod('getCurrentAccessToken');
    if (accessToken == null) {
      return null;
    }
    return new KakaoAccessToken(accessToken);
  }

  // HashKey Method
  Future<String> get hashKey async {
    final String hashKey = await _channel.invokeMethod('hashKey');
    if (hashKey == null) {
      return null;
    }
    return hashKey;
  }

  // Get UserMe Method
  Future<dynamic> getUserMe() async {
    try {
      final result = await _channel.invokeMethod('getUserMe');
      return _delayedToResult(
          new KakaoLoginResult._(result.cast<String, dynamic>()));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Login Method
  Future<dynamic> logIn() async {
    try {
      final result = await _channel.invokeMethod('logIn');
      return _delayedToResult(
          new KakaoLoginResult._(result.cast<String, dynamic>()));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Logout Method
  Future<dynamic> logOut() async {
    try {
      final result = await _channel.invokeMethod('logOut');
      return _delayedToResult(
          new KakaoLoginResult._(result.cast<String, dynamic>()));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Unlink Method
  Future<dynamic> unlink() async {
    try {
      final result = await _channel.invokeMethod('unlink');
      return _delayedToResult(
          new KakaoLoginResult._(result.cast<String, dynamic>()));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // Helper Delayed Method
  Future<T> _delayedToResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 500), () => result);
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
        account = new KakaoAccountResult._(map);

  static KakaoLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return KakaoLoginStatus.loggedIn;
      case 'loggedOut':
        return KakaoLoginStatus.loggedOut;
      case 'unlinked':
        return KakaoLoginStatus.unlinked;
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
  final String userGender;
  final String userAgeRange;
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
        userBirthday = map['userBirthday'],
        userProfileImagePath = map['userProfileImagePath'],
        userThumbnailImagePath = map['userThumbnailImagePath'];
}

// AccessToken Class
class KakaoAccessToken {
  String token;

  KakaoAccessToken(this.token);
}
