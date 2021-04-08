# Flutter Kakao Login PlugIn

![](./doc/images/kakao_login_large_narrow.png)

[![pub](https://img.shields.io/pub/v/flutter_kakao_login.svg?style=flat)](https://pub.dev/packages/flutter_kakao_login)

A Flutter plugin for using the native Kakao Login SDKs on Android and iOS.

The source is designed in the Kakao API V2 version. (start updated 2021.02.20)

## KakaoSDK Version using in plugin

- iOS SDK Version 2.0.1
- Android SDK Version 2.4.2

## Required

- iOS Required : Deployment Target 11.0 Higher.
- Android Required : Compile SDK 28 Higher.

## Installation

See the [installation by pub](https://pub.dev/packages/flutter_kakao_login).

### Android

See the [setup instructions detail](https://developers.kakao.com/docs/android/getting-started).

#### Setup :: tools version

Set to tools 3.6.1 or higher

- File Location: android/build.gradle

```
dependencies {
    ...
    classpath 'com.android.tools.build:gradle:3.6.1'
}
```

#### Setup :: gradle version

Set to gradle 5.6.4 or higher

- File Location: android/gradle.wrapper/gradle-wrapper.properties

```
distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.4-all.zip
```

#### Setup :: proguard-kakao.pro

First, create proguard-kakao.pro file.

- File Location: android/app/proguard-kakao.pro

```
# kakao login
-keep class com.kakao.sdk.**.model.* { <fields>; }
-keep class * extends com.google.gson.TypeAdapter
```

Second, You need to apply ProGuard to your project.

- File Location: android/app/build.gradle

```
buildTypes {
    release {
        ...
        proguardFiles 'proguard-kakao.pro'
    }
}
```

#### Setup :: AndroidManifest.xml

```xml
<!-- 1. Setup Require -->
<uses-permission android:name="android.permission.INTERNET" />

<application>
    <activity
        ...
        android:name=".SampleLoginActivity">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>

    <!-- 2. Setup Kakao -->
    <activity android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <!-- Redirect URI: "kakao{NATIVE_APP_KEY}://oauth“ -->
            <data android:host="oauth"
                android:scheme="kakao0123456789abcdefghijklmn" />
        </intent-filter>
    </activity>
    ...
</application>
```

### iOS

See the [setup instructions detail](https://developers.kakao.com/docs/ios#%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD-%EA%B5%AC%EC%84%B1).

#### Setup :: AppDelegate.swift

See the [example/ios/Runner/AppDelegate.swift](https://github.com/JosephNK/flutter_kakao_login/blob/master/example/ios/Runner/AppDelegate.swift)

#### Setup :: Info.plist

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

## Example

See [example/lib/main.dart](https://github.com/JosephNK/flutter_kakao_login/blob/master/example/lib/main.dart) for details.

- Kakao SDK Init (Set NATIVE_APP_KEY)

```dart
await kakaoSignIn.init("0123456789abcdefghijklmn");
```

- Login Example

```dart
try {
    final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
    final result = await kakaoSignIn.logIn();
    // To-do Someting ...
} on PlatformException catch (e) {
    print("${e.code} ${e.message}");
}
```

- Logout Example

```dart
try {
    final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
    final result = await kakaoSignIn.logOut();
    // To-do Someting ...
} on PlatformException catch (e) {
    print("${e.code} ${e.message}");
}
```

- Unlink Example

```dart
try {
    final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
    final result = await kakaoSignIn.unlink();
    // To-do Someting ..
} on PlatformException catch (e) {
    print("${e.code} ${e.message}");
}
```

- Get AccessToken Example

```dart
final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
final KakaoToken token = await (kakaoSignIn.currentToken);
final accessToken = token.accessToken;
if (accessToken != null) {
    // To-do Someting ...
}
```

- Get RefreshToken Example

```dart
final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
final KakaoToken token = await (kakaoSignIn.currentToken);
final refreshToken = token.refreshToken;
if (refreshToken != null) {
    // To-do Someting ...
}
```

- Get UserMe Example

```dart
try {
    final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();
    final result = await kakaoSignIn.getUserMe();
    final KakaoAccountResult account = result.account;
    if (account != null) {
        final KakaoAccountResult account = result.account;
        final userID = account.userID;
        final userEmail = account.userEmail;
        final userPhoneNumber = account.userPhoneNumber;
        final userDisplayID = account.userDisplayID;
        final userNickname = account.userNickname;
        final userGender = account.userGender;
        final userAgeRange = account.userAgeRange;
        final userBirthday = account.userBirthday;
        final userProfileImagePath = account.userProfileImagePath;
        final userThumbnailImagePath = account.userThumbnailImagePath;
        // To-do Someting ...
    }
} on PlatformException catch (e) {
    print("${e.code} ${e.message}");
}
```

## Contributors

Thank you for your interest in the source and for your help :)

| github                                    | email                                  |
| :---------------------------------------- | :------------------------------------- |
| [**@amond**](https://github.com/amondnet) | [**amond@amond.net**](amond@amond.net) |
| [**@myriky**](https://github.com/myriky)  | [**riky@myriky.net**](riky@myriky.net) |
| [**@kunkaamd**](https://github.com)       |
