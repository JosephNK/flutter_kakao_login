import Flutter
import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

//public class SwiftFlutterKakaoLoginPlugin: FlutterPluginAppLifeCycleDelegate, FlutterPlugin {
public class SwiftFlutterKakaoLoginPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_kakao_login", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterKakaoLoginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            KakaoSDKCommon.initSDK(appKey: call.arguments as! String)
            result(true)
            break;
        case "logIn":
            logIn(result: result)
            break
        case "logOut":
            logOut(result: result)
            break
        case "accessTokenInfo":
            getAccessTokenInfo(result: result)
            break
        case "getCurrentToken":
            getCurrentTokenInfo(result: result)
            break
        case "getUserMe":
            getUserMe(result: result)
            break
        case "unlink":
            unlink(result: result)
            break
        case "hashKey":
            result("")
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

    // Login
    private func logIn(result: @escaping FlutterResult) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    let errorMessage = error.localizedDescription
                    result(FlutterError(code: "LOGIN_ERR", message: errorMessage, details: nil))
                } else {
                    print("loginWithKakaoTalk() success.")
                    var resultMap: Dictionary<String, Any> = [
                        "status" : "loggedIn"
                    ]
                    if let token = oauthToken?.toJson {
                        resultMap["token"] = token
                    }
                    result(resultMap)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                    let errorMessage = error.localizedDescription
                    result(FlutterError(code: "LOGIN_ERR", message: errorMessage, details: nil))
                } else {
                    print("loginWithKakaoAccount() success.")
                    var resultMap: Dictionary<String, Any> = [
                        "status" : "loggedIn"
                    ]
                    if let token = oauthToken?.toJson {
                        resultMap["token"] = token
                    }
                    result(resultMap)
                }
            }
        }
    }
    
    // Logout
    private func logOut(result: @escaping FlutterResult) {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
                let errorMessage = error.localizedDescription
                result(FlutterError(code: "LOGOUT_ERR", message: errorMessage, details: nil))
            } else {
                print("logout() success.")
                let resultMap: Dictionary<String, Any> = [
                    "status" : "loggedOut"
                ]
                result(resultMap)
              }
        }
    }
    
    // Get Access Token
    private func getAccessTokenInfo(result: @escaping FlutterResult) {
        UserApi.shared.accessTokenInfo {(accessTokenInfo, error) in
            if let error = error {
                print(error)
                let errorMessage = error.localizedDescription
                result(FlutterError(code: "TOKEN_INFO_ERR", message: errorMessage, details: nil))
            } else {
                print("accessTokenInfo() success.")
                if let _accessTokenInfo = accessTokenInfo {
                    let resultMap: Dictionary<String, Any> = [
                        "id" : _accessTokenInfo.id ?? 0,
                        "expiresIn" : _accessTokenInfo.expiresIn
                    ]
                    result(resultMap)
                }
            }
        }
    }
    
    // Get Current TokenInfo
    private func getCurrentTokenInfo(result: @escaping FlutterResult) {
        let token = AUTH.tokenManager.getToken()
        if let _token = token {
            result(_token.toJson)
        } else {
            result(FlutterError(code: "TOKEN_IS_NOT_EXISTS", message: "Saved token is not exists.", details: nil))
        }
    }
    
    // Get User Me
    private func getUserMe(result: @escaping FlutterResult) {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
                let errorMessage = error.localizedDescription
                result(FlutterError(code: "USERME_ERR", message: errorMessage, details: nil))
            } else {
                print("me() success.")
                // 추가 항목 동의 받기
                if let user = user {
                    var scopes = [String]()

                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                    if (user.kakaoAccount?.birthdayNeedsAgreement == true) { scopes.append("birthday") }
                    if (user.kakaoAccount?.birthyearNeedsAgreement == true) { scopes.append("birthyear") }
                    if (user.kakaoAccount?.ciNeedsAgreement == true) { scopes.append("account_ci") }
                    if (user.kakaoAccount?.legalNameNeedsAgreement == true) { scopes.append("legal_name") }
                    if (user.kakaoAccount?.legalBirthDateNeedsAgreement == true) { scopes.append("legal_birth_date") }
                    if (user.kakaoAccount?.legalGenderNeedsAgreement == true) { scopes.append("legal_gender") }

                    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) { scopes.append("phone_number") }
                    if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
                    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) { scopes.append("age_range") }

                    if scopes.count > 0 {
                        // 필요한 scope으로 토큰갱신을 한다.
                        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (_, error) in
                            if let error = error {
                                print(error)
                                let errorMessage = error.localizedDescription
                                result(FlutterError(code: "USER_AGREE_ERR", message: errorMessage, details: nil))
                            } else {
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        print("me() success.")
                                        var resultMap: Dictionary<String, Any> = ["status" : "loggedIn"]
                                        resultMap["account"] = self.getAccountResult(user: user)
                                        result(resultMap)
                                    }
                                }
                            }
                        }
                    } else {
                        var resultMap: Dictionary<String, Any> = ["status" : "loggedIn"]
                        resultMap["account"] = self.getAccountResult(user: user)
                        result(resultMap)
                    }
                }
            }
        }
    }

    // Unlink
    private func unlink(result: @escaping FlutterResult) {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
                let errorMessage = error.localizedDescription
                result(FlutterError(code: "UNLINK_ERR", message: errorMessage, details: nil))
            } else {
                print("unlink() success.")
                let resultMap: Dictionary<String, Any> = [
                    "status" : "unlinked"
                ]
                result(resultMap)
            }
        }
    }
    
    // Get Account Result
    private func getAccountResult(user: User?) -> Dictionary<String, Any> {
        let userID = String(user?.id ?? 0)
        let userEmail = user?.kakaoAccount?.email ?? ""
              let userNickname = user?.kakaoAccount?.profile?.nickname ?? ""
        let userProfileImagePath = user?.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? ""
        let userThumbnailImagePath = user?.kakaoAccount?.profile?.thumbnailImageUrl?.absoluteString ?? ""
              let userPhoneNumber = user?.kakaoAccount?.phoneNumber ?? ""
              let userDisplayID = user?.kakaoAccount?.email ?? user?.kakaoAccount?.phoneNumber ?? ""
              var userGender = ""
        let gender = user?.kakaoAccount?.gender
        switch gender {
        case .Male:
            userGender = "MALE"
            break
        case .Female:
            userGender = "FEMALE"
            break
        case .none:
            userGender = ""
            break
        }
        var userAgeRange = ""
        let ageRange = user?.kakaoAccount?.ageRange
        switch ageRange {
        case .Age0_9:
            userAgeRange = "0세~9세"
            break
        case .Age10_14:
            userAgeRange = "10세~14세"
            break
        case .Age15_19:
            userAgeRange = "15세~19세"
            break
        case .Age20_29:
            userAgeRange = "20세~29세"
            break
        case .Age30_39:
            userAgeRange = "30세~39세"
            break
        case .Age40_49:
            userAgeRange = "40세~49세"
            break
        case .Age50_59:
            userAgeRange = "50세~59세"
            break
        case .Age60_69:
            userAgeRange = "60세~69세"
            break
        case .Age70_79:
            userAgeRange = "70세~79세"
            break
        case .Age80_89:
            userAgeRange = "80세~89세"
            break
        case .Age90_Above:
            userAgeRange = "90세 이상"
            break
        case .none:
            userAgeRange = ""
            break
        }
        let userBirthyear = user?.kakaoAccount?.birthyear ?? ""
        let userBirthday = user?.kakaoAccount?.birthday ?? ""
        
        
        let account: Dictionary<String, Any> = [
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
        ]
        
        return account
    }

//    override public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        if (AuthApi.isKakaoTalkLoginUrl(url)) {
//            return AuthController.handleOpenUrl(url: url)
//        }
//        return false
//    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension OAuthToken {
    var toJson: Dictionary<String, Any?> {
        return [
            "accessToken" : accessToken,
            "accessTokenExpiresAt" :expiredAt.millisecondsSince1970,
            "refreshToken" : refreshToken,
            "refreshTokenExpiresAt" : refreshTokenExpiredAt.millisecondsSince1970,
            "scopes" : scopes ?? []
        ]
    }
}
