import Flutter
import UIKit
import KakaoOpenSDK
import KakaoLink

public class SwiftFlutterKakaoLoginPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_kakao_login", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterKakaoLoginPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "logIn":
        // ensure old session was closed
        KOSession.shared()?.close()
        
        KOSession.shared()?.open(completionHandler: { (error) in
            let isOpen = KOSession.shared()?.isOpen() ?? false
            if isOpen {
                // login success
                KOSessionTask.userMeTask { (error, me) in
                    if error != nil {
                        let errorMessage = error != nil ? error!.localizedDescription : "Unknown Error"
                        result(FlutterError(code: "LOGIN_ERR", message: errorMessage, details: nil))
                    } else {
                        let userID = me?.id ?? ""
                        let userEmail = me?.account?.email ?? ""
                        result([
                            "status" : "loggedIn",
                            "userID" : userID,
                            "userEmail" : userEmail
                        ])
                    }
                }
            } else {
                let errorMessage = error != nil ? error!.localizedDescription : "Unknown Error"
                result(FlutterError(code: "OPEN_ERR", message: errorMessage, details: nil))
            }
        }, authTypes: [NSNumber(value: KOAuthType.talk.rawValue)])
        break
    case "logOut":
        KOSession.shared()?.logoutAndClose(completionHandler: { (success, error) in
            if error != nil {
                let errorMessage = error != nil ? error!.localizedDescription : "Unknown Error"
                result(FlutterError(code: "LOGOUT_ERR", message: errorMessage, details: nil))
            } else {
                result([
                    "status" : "loggedOut"
                ])
            }
        })
        break
    case "getUserMe":
        KOSessionTask.userMeTask(withPropertyKeys: [
            "properties.nickname",
            "properties.profile_image",
            "properties.thumbnail_image",
            "kakao_account.profile",
            "kakao_account.email",
            "kakao_account.age_range",
            "kakao_account.birthday",
            "kakao_account.gender"
        ]) { (error, me) in
            if error != nil {
                let errorMessage = error != nil ? error!.localizedDescription : "Unknown Error"
                result(FlutterError(code: "USERME_ERR", message: errorMessage, details: nil))
            } else {
                let userID = me?.id ?? ""
                let userEmail = me?.account?.email ?? ""
                let userNickname = me?.properties?["nickname"] ?? ""
                let userProfileImagePath = me?.properties?["profile_image"] ?? ""
                let userThumbnailImagePath = me?.properties?["thumbnail_image"] ?? ""
                let userPhoneNumber = me?.account?.phoneNumber ?? ""
                let userDisplayID = me?.account?.displayID ?? ""
                var userGender = ""
                let gender = me?.account?.gender ?? KOUserGender.null
                switch gender {
                case .null:
                    userGender = ""
                    break
                case .male:
                    userGender = "MALE"
                    break
                case .female:
                    userGender = "FEMALE"
                    break
                @unknown default:
                    break
                }
                var userAgeRange = ""
                let ageRange = me?.account?.ageRange ?? KOUserAgeRange.null
                switch ageRange {
                case .null:
                    userAgeRange = ""
                    break
                case .type0:
                    userAgeRange = "0세~9세"
                    break
                case .type10:
                    userAgeRange = "10세~14세"
                    break
                case .type15:
                    userAgeRange = "15세~19세"
                    break
                case .type20:
                    userAgeRange = "20세~29세"
                    break
                case .type30:
                    userAgeRange = "30세~39세"
                    break
                case .type40:
                    userAgeRange = "40세~49세"
                    break
                case .type50:
                    userAgeRange = "50세~59세"
                    break
                case .type60:
                    userAgeRange = "60세~69세"
                    break
                case .type70:
                    userAgeRange = "70세~79세"
                    break
                case .type80:
                    userAgeRange = "80세~89세"
                    break
                case .type90:
                    userAgeRange = "90세 이상"
                    break
                @unknown default:
                    break
                }
                let userBirthyear = me?.account?.birthyear ?? ""
                let userBirthday = me?.account?.birthday ?? ""
                
                result([
                    "status" : "loggedIn",
                    "userID" : userID,
                    "userNickname" : userNickname,
                    "userProfileImagePath" : userProfileImagePath,
                    "userThumbnailImagePath" : userThumbnailImagePath,
                    "userEmail" : userEmail,
                    "userPhoneNumber" : userPhoneNumber,
                    "userDisplayID" : userDisplayID,
                    "userGender" : userGender,
                    "userAgeRange" : userAgeRange,
                    "userBirthyear" : userBirthyear,
                    "userBirthday" : userBirthday
                ])
            }
        }
        break
    case "getCurrentAccessToken":
        let accessToken = KOSession.shared()?.token?.accessToken
        result(accessToken)
        break
    case "getCurrentRefreshToken":
        let refreshToken = KOSession.shared()?.token?.refreshToken
        result(refreshToken)
        break
    case "unlink":
        KOSessionTask.unlinkTask { (success, error) in
            if success {
                result([
                    "status" : "unlinked"
                ])
            } else {
                if error != nil {
                    let errorMessage = error != nil ? error!.localizedDescription : "Unknown Error"
                    result(FlutterError(code: "UNLINK_ERR", message: errorMessage, details: nil))
                } else {
                    result(nil)
                }
            }
        }
        break
    case "hashKey":
        result("")
        break
    default:
        result(FlutterMethodNotImplemented)
        break
    }
  }
}
