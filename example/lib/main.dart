import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_kakao_login/flutter_kakao_login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FlutterKakaoLogin kakaoSignIn = new FlutterKakaoLogin();

  String _message = 'Log in/out by pressing the buttons below.';
  String _accessToken = 'AccessToken is None';

  @override
  initState() {
    super.initState();
  }

  Future<Null> _login() async {
    final KakaoLoginResult result = await kakaoSignIn.logIn();
    _processResult(result);
  }

  Future<Null> _logOut() async {
    final KakaoLoginResult result = await kakaoSignIn.logOut();
    _processResult(result);
  }

  Future<Null> _getAccessToken() async {
    final KakaoAccessToken accessToken = await (kakaoSignIn.currentAccessToken);
    if (accessToken != null) {
      final token = accessToken.token;
      _updateAccessToken('AccessToken is \n' + token);
    } else {
      _updateAccessToken('AccessToken is None');
    }
  }

  void _updateMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void _updateAccessToken(String accessToken) {
    setState(() {
      _accessToken = accessToken;
    });
  }

  void _processResult(KakaoLoginResult result) {
    switch (result.status) {
      case KakaoLoginStatus.loggedIn:
        _updateMessage('LoggedIn by the user.\n'
        '- UserID is ${result.userID}\n'
        '- UserEmail is ${result.userEmail} ');

        _getAccessToken();
        break;
      case KakaoLoginStatus.loggedOut:
        _updateMessage('LoggedOut by the user.');

        _getAccessToken();
        break;
      case KakaoLoginStatus.error:
        _updateMessage('This is Kakao error message : ${result.errorMessage}');

        _getAccessToken();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Kakao Login Plugin app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                  color: Colors.black12,
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: new Text(
                    _message,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    style: new TextStyle(fontWeight: FontWeight.bold)
                  ),
              ),
              new Container(
                  //color: Colors.black12,
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 30.0, right: 30.0),
                  child: new Text(
                    _accessToken,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    style: new TextStyle(fontWeight: FontWeight.bold)
                  ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: new RaisedButton(
                  onPressed: _login,
                  child: new Text('Log in'),
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 0.0, bottom: 15.0),
                child: new RaisedButton(
                  onPressed: _logOut,
                  child: new Text('Logout'),
                ),
              ),
              new Container(
                child: new RaisedButton(
                  onPressed: _getAccessToken,
                  child: new Text('Get AccessToken'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
