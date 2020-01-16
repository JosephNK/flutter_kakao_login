package com.josephnk.flutterkakaologin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.kakao.auth.ApiErrorCode;
import com.kakao.auth.ApprovalType;
import com.kakao.auth.AuthType;
import com.kakao.auth.IApplicationConfig;
import com.kakao.auth.ISessionCallback;
import com.kakao.auth.ISessionConfig;
import com.kakao.auth.KakaoAdapter;
import com.kakao.auth.KakaoSDK;

import com.kakao.auth.Session;
import com.kakao.auth.authorization.accesstoken.AccessToken;
import com.kakao.network.ErrorResult;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;
import com.kakao.usermgmt.callback.MeV2ResponseCallback;
import com.kakao.usermgmt.callback.UnLinkResponseCallback;
import com.kakao.usermgmt.response.MeV2Response;
import com.kakao.usermgmt.response.model.UserAccount;
import com.kakao.util.exception.KakaoException;
import com.kakao.util.helper.log.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * FlutterKakaoLoginPlugin
 */
public class FlutterKakaoLoginPlugin
    implements FlutterPlugin, ActivityAware {

  private static final String CHANNEL_NAME = "flutter_kakao_login";

  private static final String LOG_TAG = "KakaoTalkPlugin";

  private Activity activity;
  private MethodChannel channel;
  private FlutterKakaoLoginHandler handler;

  /**
    * Plugin registration.
    * for legacy Embedding API
    */
  public static void registerWith(Registrar registrar) {
    Activity activity = registrar.activity();
    if (activity == null) {
      return;
    }

    final FlutterKakaoLoginPlugin instance = new FlutterKakaoLoginPlugin();
    instance.onAttachedToEngine(registrar.messenger());
    instance.onAttachedToActivity(activity);
  }


  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.getBinaryMessenger());
  }

  private void onAttachedToEngine(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);

    if (activity != null) {
      handler = new FlutterKakaoLoginHandler(activity, channel);
      channel.setMethodCallHandler(handler);
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    handler = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding.getActivity());
  }

  private void onAttachedToActivity(Activity _activity) {
    activity = _activity;

    if (activity != null && channel != null) {
      handler = new FlutterKakaoLoginHandler(activity, channel);
      channel.setMethodCallHandler(handler);
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding.getActivity());
    // after a configuration change.
  }

  @Override
  public void onDetachedFromActivity() {
    channel.setMethodCallHandler(null);
    activity = null;
    handler = null;
  }

}
