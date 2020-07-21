package com.josephnk.flutter_kakao_login

import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import com.kakao.auth.*
import com.kakao.network.ErrorResult
import com.kakao.usermgmt.UserManagement
import com.kakao.usermgmt.callback.LogoutResponseCallback
import com.kakao.usermgmt.callback.MeV2ResponseCallback
import com.kakao.usermgmt.callback.UnLinkResponseCallback
import com.kakao.usermgmt.response.MeV2Response
import com.kakao.usermgmt.response.model.Gender
import com.kakao.util.exception.KakaoException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.security.MessageDigest

/** FlutterKakaoLoginPlugin */
public class FlutterKakaoLoginPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel : MethodChannel

  private var activity: Activity? = null
  private var sessionCallback: KakaoSessionCallback? = null
  private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())

  companion object {
    private var registrar : Registrar? = null
    private const val name = "flutter_kakao_login"
    private const val TAG = "FlutterKakaoLogin"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      Log.d(TAG, "registerWith")
      val activity = registrar.activity() ?: return
      FlutterKakaoLoginPlugin.registrar = registrar

      val instance = FlutterKakaoLoginPlugin()
      instance.onInstanceAtAttachedToEngine(registrar.messenger())
      instance.onInstanceAtAttachedToActivity(activity)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    //channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), name)
    //channel.setMethodCallHandler(this);
    Log.d(TAG, "onAttachedToEngine")
    onInstanceAtAttachedToEngine(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(TAG, "onDetachedFromEngine")
    onDetachedFromActivity()
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val methodResult: Result = result

    when (call.method) {
      "logIn" -> {
        Log.d(TAG, "onMethodCall logIn")

        // ensure old session was closed
        Session.getCurrentSession().close()

        sessionCallback = KakaoSessionCallback(methodResult)
        Session.getCurrentSession().addCallback(sessionCallback)
        Session.getCurrentSession().open(AuthType.KAKAO_TALK, activity)
      }
      "logOut" -> {
        Log.d(TAG, "onMethodCall logOut")
        logout(methodResult)
      }
      "getCurrentAccessToken" -> {
        Log.d(TAG, "onMethodCall getCurrentAccessToken")
        val tokenInfo = Session.getCurrentSession().tokenInfo
        val accessToken = tokenInfo.accessToken
        methodResult.success(accessToken)
      }
      "getUserMe" -> {
        Log.d(TAG, "onMethodCall getUserMe")
        requestMe(methodResult)
      }
      "unlink" -> {
        Log.d(TAG, "onMethodCall unlink")
        unlink(methodResult)
      }
      "hashKey" -> {
        Log.d(TAG, "onMethodCall hashKey")
        if (activity != null) {
          val hashKey = Util.getKeyHash(activity!!)
          Log.d(TAG, "hashKey: $hashKey")
          methodResult.success(hashKey)
        }
      }
      else -> result.notImplemented()
    }
  }

  // Instance Method
  //
  private fun onInstanceAtAttachedToEngine(messenger: BinaryMessenger) {
    Log.d(TAG, "onInstanceAtAttachedToEngine")
    channel = MethodChannel(messenger, name)
    channel.setMethodCallHandler(this)
  }

  private fun onInstanceAtAttachedToActivity(_activity: Activity) {
    Log.d(TAG, "onInstanceAtAttachedToActivity")
    activity = _activity
    if (activity != null && channel != null) {
      try {
        KakaoSDK.init(KakaoSDKAdapter(activity!!))
      } catch (e: RuntimeException) {
        Log.e("KakaoTag", "error", e)
      }
    }
  }

  // PluginRegistry.ActivityResultListener
  //
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    Log.d(TAG, "onActivityResult")
    if (Session.getCurrentSession().handleActivityResult(requestCode, resultCode, data)) {
      return true
    }
    return false
  }

  // ActivityAware
  //
  override fun onDetachedFromActivity() {
    Log.d(TAG, "onDetachedFromActivity")
    channel.setMethodCallHandler(null)
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(TAG, "onReattachedToActivityForConfigChanges")
    onInstanceAtAttachedToActivity(binding.activity)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(TAG, "onAttachedToActivity")
    onInstanceAtAttachedToActivity(binding.activity)
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "onDetachedFromActivityForConfigChanges")
    onDetachedFromActivity()
  }

  // KakaoSessionCallback
  //
  inner class KakaoSessionCallback(result: Result) : ISessionCallback {
    var methodResult: Result = result

    fun removeCallback() {
      Log.d(TAG, "KakaoSessionCallback removeCallback")
      Session.getCurrentSession().removeCallback(sessionCallback)
    }

    override fun onSessionOpened() {
      Log.d(TAG, "KakaoSessionCallback Open")
      UserManagement.getInstance().me(object : MeV2ResponseCallback() {
        override fun onSessionClosed(errorResult: ErrorResult?) {
          Log.d(TAG, "failed to update profile. msg = $errorResult")
          removeCallback()

          val errorMessage = errorResult?.errorMessage ?: ""
          methodResult.error( "LOGIN_ERR", errorMessage, "")
        }
        override fun onSuccess(resultKakao: MeV2Response?) {
          Log.d(TAG, "success to update profile. msg = $resultKakao")
          removeCallback()

          val userID = resultKakao?.id ?: ""
          val kakaoAccount = resultKakao?.kakaoAccount
          val userEmail = kakaoAccount?.email ?: ""

          val context = HashMap<String, String>()
          context["status"] = "loggedIn"
          context["userID"] = userID.toString()
          context["userEmail"] = userEmail
          methodResult.success(context)
        }
      })
    }

    override fun onSessionOpenFailed(exception: KakaoException) {
      Log.d(TAG, exception.message)

      val errorMessage = exception.toString()
      methodResult.error( "OPEN_ERR", errorMessage, "")
    }
  }

  // logout
  //
  private fun logout(result: Result) {
    var methodResult: Result = result

    UserManagement.getInstance().requestLogout(object : LogoutResponseCallback() {
      override fun onCompleteLogout() {
        uiThreadHandler.post(Runnable {
          val context = HashMap<String, String>()
          context["status"] = "loggedOut"
          methodResult.success(context)
        })
      }
    })
  }

  // requestMe
  private fun requestMe(result: Result) {
    val methodResult: Result = result

    val keys: List<String> = listOf(
            "properties.nickname",
            "properties.profile_image",
            "properties.thumbnail_image",
            "kakao_account.email"
    )

    UserManagement.getInstance().me(keys, object : MeV2ResponseCallback() {
      override fun onFailure(errorResult: ErrorResult?) {
        val errorMessage = errorResult?.errorMessage ?: ""
        methodResult.error( "USERME_ERR", errorMessage, "")
      }

      override fun onSessionClosed(errorResult: ErrorResult?) {
        val errorMessage = errorResult?.errorMessage ?: ""
        methodResult.error( "OPEN_ERR", errorMessage, "")
      }

      override fun onSuccess(response: MeV2Response?) {
        val userAccount = response?.kakaoAccount
        val userID = response?.id
        val userNickname = userAccount?.profile?.nickname ?: ""
        val userProfileImagePath = userAccount?.profile?.profileImageUrl ?: ""
        val userThumbnailImagePath = userAccount?.profile?.thumbnailImageUrl ?: ""
        val userEmail = userAccount?.email ?: ""
        val userPhoneNumber = userAccount?.phoneNumber ?: ""
        val userDisplayID = userAccount?.displayId ?: ""
        val gender = userAccount?.gender ?: Gender.UNKNOWN
        var userGender = ""
        when (gender) {
          Gender.MALE -> {
            userGender = "MALE"
          }
          Gender.FEMALE -> {
            userGender = "FEMALE"
          }
        }
        val userAgeRange = userAccount?.ageRange?.value ?: ""
        val userBirthday = userAccount?.birthday ?: ""

        val context = HashMap<String, String>()
        context["status"] = "loggedIn"
        context["userID"] = userID.toString()
        context["userNickname"] = userNickname
        context["userProfileImagePath"] = userProfileImagePath
        context["userThumbnailImagePath"] = userThumbnailImagePath
        context["userEmail"] = userEmail
        context["userPhoneNumber"] = userPhoneNumber
        context["userDisplayID"] = userDisplayID
        context["userGender"] = userGender
        context["userAgeRange"] = userAgeRange
        context["userBirthday"] = userBirthday
        methodResult.success(context)
      }
    })
  }

  // unlink
  //
  private fun unlink(result: Result) {
    val methodResult: Result = result

    UserManagement.getInstance().requestUnlink(object : UnLinkResponseCallback() {
      override fun onFailure(errorResult: ErrorResult?) {
        val errorMessage = errorResult?.errorMessage ?: ""
        methodResult.error( "UNLINK_ERR", errorMessage, "")
      }

      override fun onSessionClosed(errorResult: ErrorResult) {
        val errorMessage = errorResult?.errorMessage ?: ""
        methodResult.error( "UNLINK_ERR", errorMessage, "")
      }

      override fun onNotSignedUp() {
        val errorCode = ApiErrorCode.NOT_REGISTERED_USER_CODE.toString()
        val errorMessage = "NOT_REGISTERED_USER_CODE"
        methodResult.error("UNLINK_ERR_$errorCode", errorMessage, "")
      }

      override fun onSuccess(userId: Long?) {
        val context = HashMap<String, String>()
        context["status"] = "unlinked"
        //context["userID"] = userId.toString()
        methodResult.success(context)
      }
    })
  }
}

// KakaoSDKAdapter
//
class KakaoSDKAdapter(activity: Activity) : KakaoAdapter() {
  private var currentActivity: Activity = activity

  override fun getSessionConfig(): ISessionConfig {
    return object : ISessionConfig {
      override fun getAuthTypes(): Array<AuthType> {
        return arrayOf(AuthType.KAKAO_ACCOUNT)
      }

      override fun isUsingWebviewTimer(): Boolean {
        return false
      }

      override fun getApprovalType(): ApprovalType? {
        return ApprovalType.INDIVIDUAL
      }

      override fun isSaveFormData(): Boolean {
        return true
      }

      override fun isSecureMode(): Boolean {
        return true
      }
    }
  }

  override fun getApplicationConfig(): IApplicationConfig {
    return IApplicationConfig {
      currentActivity.applicationContext
    }
  }
}

// Util
//
object Util {
  @TargetApi(Build.VERSION_CODES.P)
  fun getKeyHash(context: Context): String {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      val packageInfo = context.packageManager
              .getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
      val signatures = packageInfo.signingInfo.signingCertificateHistory
      for (signature in signatures) {
        val md = MessageDigest.getInstance("SHA")
        md.update(signature.toByteArray())
        return Base64.encodeToString(md.digest(), Base64.NO_WRAP)
      }
      throw IllegalStateException()
    }
    val packageInfo = context.packageManager
            .getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES)
    for (signature in packageInfo.signatures) {
      val md = MessageDigest.getInstance("SHA")
      md.update(signature.toByteArray())
      return Base64.encodeToString(md.digest(), Base64.NO_WRAP)
    }
    throw IllegalStateException()
  }
}