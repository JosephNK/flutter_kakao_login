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

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * FlutterKakaoLoginPlugin
 */
public class FlutterKakaoLoginHandler
    implements MethodChannel.MethodCallHandler {

  private static final String LOG_TAG = "KakaoTalkPlugin";

  private static final String METHOD_LOG_IN = "logIn";
  private static final String METHOD_LOG_OUT = "logOut";
  private static final String METHOD_GET_CURRENT_ACCESS_TOKEN = "getCurrentAccessToken";
  private static final String METHOD_GET_USER_ME = "getUserMe";
  private static final String METHOD_UNLINK = "unlink";

  private final Activity activity;
  private final MethodChannel channel;

  private SessionCallback sessionCallback;

  public FlutterKakaoLoginHandler(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;

    try {
      KakaoSDK.init(new KakaoSDKAdapter(this.activity));
    } catch (RuntimeException e) {
      Log.e("kakao init error", "error", e);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    final MethodChannel.Result _result = result;

    switch (call.method) {
      case METHOD_LOG_IN:
        // ensure old session was closed
        Session.getCurrentSession().close();

        sessionCallback = new FlutterKakaoLoginHandler.SessionCallback(_result);
        Session.getCurrentSession().addCallback(sessionCallback);
        Session.getCurrentSession().open(AuthType.KAKAO_TALK, activity);
        break;
      case METHOD_LOG_OUT:
        UserManagement.getInstance().requestLogout(new LogoutResponseCallback() {
          @Override
          public void onCompleteLogout() {
            _result.success(new HashMap<String, String>() {
              {
                put("status", "loggedOut");
              }
            });
          }
        });
        break;
      case METHOD_GET_CURRENT_ACCESS_TOKEN:
        AccessToken tokenInfo = Session.getCurrentSession().getTokenInfo();
        String accessToken = tokenInfo.getAccessToken();
        _result.success(accessToken);
        break;
      case METHOD_GET_USER_ME:
        requestMe(_result);
        break;
      case METHOD_UNLINK:
        unlink(_result);
      default:
        result.notImplemented();
        break;
    }
  }


  /**
   * Get UserMe
   */
  public void requestMe(MethodChannel.Result result) {
    final MethodChannel.Result _result = result;

    List<String> keys = new ArrayList<>();
    keys.add("properties.nickname");
    keys.add("properties.profile_image");
    keys.add("properties.thumbnail_image");
    keys.add("kakao_account.email");

    UserManagement.getInstance().me(keys, new MeV2ResponseCallback() {
      @Override
      public void onFailure(ErrorResult errorResult) {
        String message = "failed to get user info. msg=" + errorResult;
        Logger.d(message);
      }

      @Override
      public void onSessionClosed(ErrorResult errorResult) {
        final String errorMessage = errorResult.getErrorMessage();
        String message = "failed to get user info. msg=" + errorResult;
        Log.v(LOG_TAG, "kakao : onSessionClosed " + message);

        _result.success(new HashMap<String, String>() {
          {
            put("status", "error");
            put("errorMessage", errorMessage);
          }
        });
      }

      @Override
      public void onSuccess(MeV2Response response) {
        final UserAccount userAccount = response.getKakaoAccount(); // https://devtalk.kakao.com/t/topic/70955/2

        final Long userID = response.getId();
        final String userNickname = (response.getNickname() == null) ? "" : response.getNickname();
        final String userProfileImagePath = (response.getProfileImagePath() == null) ? ""
                : response.getProfileImagePath();
        final String userThumbnailImagePath = (response.getThumbnailImagePath() == null) ? ""
                : response.getThumbnailImagePath();
        final String userEmail = (userAccount == null) ? ""
                : (userAccount.getEmail() == null) ? "" : userAccount.getEmail();
        final String userPhoneNumber = (userAccount == null) ? ""
                : (userAccount.getPhoneNumber() == null) ? "" : userAccount.getPhoneNumber();
        final String userDisplayID = (userAccount == null) ? ""
                : (userAccount.getDisplayId() == null) ? "" : userAccount.getDisplayId();

        Log.v(LOG_TAG, "kakao : onSuccess " + "userID: " + userID + " and userEmail: " + userEmail);

        _result.success(new HashMap<String, String>() {
          {
            put("status", "loggedIn");
            put("userID", userID.toString());
            put("userNickname", userNickname);
            put("userProfileImagePath", userProfileImagePath);
            put("userThumbnailImagePath", userThumbnailImagePath);
            put("userEmail", userEmail);
            put("userPhoneNumber", userPhoneNumber);
            put("userDisplayID", userDisplayID);
          }
        });
      }

      // @Override
      // public void onNotSignedUp() {
      // }
    });
  }

  /**
   * Unlink
   */
  private void unlink(MethodChannel.Result result) {
    final MethodChannel.Result _result = result;

    UserManagement.getInstance().requestUnlink(new UnLinkResponseCallback() {
      @Override
      public void onFailure(ErrorResult errorResult) {
        Log.e(LOG_TAG, "kakao : UnLinkResponseCallback.onFailure" + errorResult);
        _result.error(String.valueOf(errorResult.getErrorCode()), errorResult.getErrorMessage(), errorResult);
      }

      /**
       * 세션이 닫혔을때 불리는 callback
       *
       * @param errorResult errorResult
       */
      @Override
      public void onSessionClosed(ErrorResult errorResult) {
        Log.e(LOG_TAG, "kakao : UnLinkResponseCallback.onSessionClosed" + errorResult);
        _result.error(String.valueOf(errorResult.getErrorCode()), errorResult.getErrorMessage(), errorResult);
      }

      /**
       * 세션 오픈은 성공했으나 사용자 정보 요청 결과 사용자 가입이 안된 상태로 일반적으로 가입창으로 이동한다. 자동 가입 앱이 아닌 경우에만
       * 호출된다.
       */
      @Override
      public void onNotSignedUp() {
        Log.e(LOG_TAG, "kakao : UnLinkResponseCallback.onNotSignedUp");
        _result.error(String.valueOf(ApiErrorCode.NOT_REGISTERED_USER_CODE), "", null);
      }

      @Override
      public void onSuccess(final Long userId) {

        Log.v(LOG_TAG, "kakao : UnLinkResponseCallback.onSuccess " + "userId: " + userId);

        _result.success(new HashMap<String, String>() {
          {
            put("status", "unlinked");
            put("userID", userId.toString());
          }
        });
      }

    });
  }

  /**
   * Class SessionCallback
   */
  private class SessionCallback implements ISessionCallback {
    private MethodChannel.Result _result;

    public SessionCallback(MethodChannel.Result result) {
      Log.v(LOG_TAG, "kakao : SessionCallback create");
      this._result = result;
    }

    private void removeCallback() {
      Session.getCurrentSession().removeCallback(sessionCallback);
    }

    @Override
    public void onSessionOpened() {
      Log.v(LOG_TAG, "kakao : SessionCallback.onSessionOpened");
      UserManagement.getInstance().me(new MeV2ResponseCallback() {
        @Override
        public void onSessionClosed(ErrorResult errorResult) {
          removeCallback();

          final String errorMessage = errorResult.getErrorMessage();
          String message = "failed to get user info. msg=" + errorResult;
          Log.v(LOG_TAG, "kakao : onSessionClosed " + message);

          _result.success(new HashMap<String, String>() {
            {
              put("status", "error");
              put("errorMessage", errorMessage);
            }
          });
        }

        @Override
        public void onSuccess(MeV2Response resultKakao) {
          removeCallback();

          final UserAccount userAccount = resultKakao.getKakaoAccount(); // https://devtalk.kakao.com/t/topic/70955/2

          final Long userID = resultKakao.getId();
          final String userEmail = (userAccount == null) ? ""
                  : (userAccount.getEmail() == null) ? "" : userAccount.getEmail();

          Log.v(LOG_TAG, "kakao : onSuccess " + "userID: " + userID + " and userEmail: " + userEmail);

          _result.success(new HashMap<String, String>() {
            {
              put("status", "loggedIn");
              put("userID", userID.toString());
              put("userEmail", userEmail);
            }
          });
        }
      });
    }

    @Override
    public void onSessionOpenFailed(KakaoException exception) {
      removeCallback();

      if (exception != null) {
        final String errorMessage = exception.toString();
        Log.v(LOG_TAG, "kakao : onSessionOpenFailed " + errorMessage);
        _result.success(new HashMap<String, String>() {
          {
            put("status", "error");
            put("errorMessage", errorMessage);
          }
        });
      }
    }
  }


  /**
   * Class KakaoSDKAdapter
   */
  private static class KakaoSDKAdapter extends KakaoAdapter {

    private final Activity currentActivity;

    public KakaoSDKAdapter(Activity activity) {
      this.currentActivity = activity;
    }

    @Override
    public ISessionConfig getSessionConfig() {
      return new ISessionConfig() {
        @Override
        public AuthType[] getAuthTypes() {
          return new AuthType[] { AuthType.KAKAO_TALK };
        }

        @Override
        public boolean isUsingWebviewTimer() {
          return false;
        }

        @Override
        public boolean isSecureMode() {
          return false;
        }

        @Override
        public ApprovalType getApprovalType() {
          return ApprovalType.INDIVIDUAL;
        }

        @Override
        public boolean isSaveFormData() {
          return false;
        }
      };
    }

    @Override
    public IApplicationConfig getApplicationConfig() {
      return new IApplicationConfig() {
        public Activity getTopActivity() {
          return currentActivity;
        }

        @Override
        public Context getApplicationContext() {
          return currentActivity.getApplicationContext();
        }
      };
    }
  }

}
