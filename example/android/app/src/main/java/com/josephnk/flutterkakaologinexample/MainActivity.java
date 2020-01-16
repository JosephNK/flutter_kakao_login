package com.josephnk.flutterkakaologinexample;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String LOG_TAG = "KakaoTalkLogin";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    String hashKey = getKeyHash(this);
    if (hashKey != null) {
      Log.v(LOG_TAG, "signature=" + hashKey);
    }
  }

  public static String getKeyHash(final Context context) {
    try {
      PackageManager pm = context.getPackageManager();
      PackageInfo info = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES);
      if (info == null) {
        return null;
      }
      for (Signature signature : info.signatures) {
        try {
          MessageDigest md = MessageDigest.getInstance("SHA");
          md.update(signature.toByteArray());
          return Base64.encodeToString(md.digest(), Base64.NO_WRAP);
        } catch (NoSuchAlgorithmException e) {
          Log.w(LOG_TAG, "Unable to get MessageDigest. signature=" + signature, e);
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
    return null;
  }

}
