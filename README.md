# Flutter Kakao Login PlugIn
A Flutter plugin for using the native Kakao Login SDKs on Android and iOS.

## KakaoSDK Version using in plugin

* iOS SDK Version 1.11.1 
* Android SDK Version  1.16.0

## Required 

* iOS Required : Deployment Target 9.0 Higher.
* Android Required : Compile SDK 28 Higher.

## Support  

* AndroidX

## Usage

See [example/lib/main.dart](https://github.com/JosephNK/flutter_kakao_login/blob/master/example/lib/main.dart) for details.

```
1. Depend on it
Add this to your package's pubspec.yaml file:

dependencies:
  flutter_kakao_login: "^0.0.8"
```
```
2. Install it
You can install packages from the command line:

with Flutter:

$ flutter packages get

Alternatively, your editor might support flutter packages get. Check the docs for your editor to learn more.
```
```
3. Import it
Now in your Dart code, you can use:

    import 'package:flutter_kakao_login/flutter_kakao_login.dart';
```
- Login & Logout Example
```dart
FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin()
final KakaoLoginResult result = await kakaoSignIn.logIn();
switch (result.status) {
    case KakaoLoginStatus.loggedIn:
        _updateMessage('LoggedIn by the user.\n'
                       '- UserID is ${result.account.userID}\n'
                       '- UserEmail is ${result.account.userEmail} ');
    break;
    case KakaoLoginStatus.loggedOut:
        _updateMessage('LoggedOut by the user.');
    break;
    case KakaoLoginStatus.error:
        _updateMessage('This is Kakao error message : ${result.errorMessage}');
    break;
}
```
- Get AccessToken Example
```dart
Future<Null> _getAccessToken() async {
    final KakaoAccessToken accessToken = await (kakaoSignIn.currentAccessToken);
    if (accessToken != null) {
      final token = accessToken.token;
      // To-do Someting ...
    }
}
```
- Get UserMe Example
```dart
Future<Null> _getAccountInfo() async {
    final KakaoLoginResult result = await kakaoSignIn.getUserMe();
    if (result != null && result.status != KakaoLoginStatus.error) {
      final KakaoAccountResult account = result.account;
      final userID = account.userID;
      final userEmail = account.userEmail;
      final userPhoneNumber = account.userPhoneNumber;
      final userDisplayID = account.userDisplayID;
      final userNickname = account.userNickname;                       
      final userProfileImagePath = account.userProfileImagePath;
      final userThumbnailImagePath = account.userThumbnailImagePath;
      // To-do Someting ...
    }
  }
```

## Installation

See the [installation by pub](https://pub.dartlang.org/packages/flutter_kakao_login).

### Android

See the [setup instructions detail](https://developers.kakao.com/docs/android/getting-started).

[kakao_strings.xml]

```xml
<resources>
    <string name="kakao_app_key">0123456789abcdefghijklmn</string>
</resources>
```

[AndroidManifest.xml]

```xml
<!-- 1 -->
<uses-permission android:name="android.permission.INTERNET" />

<application>
    <!-- 2 -->
    <activity
        ...
        android:name=".SampleLoginActivity">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>
    <!-- 3 -->
    <meta-data
        android:name="com.kakao.sdk.AppKey"
        android:value="@string/kakao_app_key" />
    <!-- 4 -->
    <activity
        android:name="com.kakao.auth.authorization.authcode.KakaoWebViewActivity"
        android:launchMode="singleTop"
        android:windowSoftInputMode="adjustResize">

        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.DEFAULT"/>
        </intent-filter>
    </activity>
    ...
</application>
```

### iOS

See the [setup instructions detail](https://developers.kakao.com/docs/ios#%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD-%EA%B5%AC%EC%84%B1).

[info.plst]

```xml
<key>KAKAO_APP_KEY</key>
<string>0123456789abcdefghijklmn</string>
```

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakao0123456789abcdefghijklmn</string>
    <string>kakaokompassauth</string>
    <string>storykompassauth</string>
    <string>kakaolink</string>
    <string>storylink</string>
</array>
```

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string></string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao0123456789abcdefghijklmn</string>
        </array>
    </dict>
</array>
```
