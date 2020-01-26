#import "FlutterKakaoLoginPlugin.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <KakaoLink/KakaoLink.h>

@implementation FlutterKakaoLoginPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_kakao_login"
                                     binaryMessenger:[registrar messenger]];
    FlutterKakaoLoginPlugin* instance = [[FlutterKakaoLoginPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"logIn" isEqualToString:call.method]) {
        // ensure old session was closed
        [[KOSession sharedSession] close];
        
        [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
            if ([[KOSession sharedSession] isOpen]) {
                // login success
                [KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *me) {
                    if (error) {
                        result(@{ @"status" : @"error",
                                  @"errorMessage" : [error description] });
                    } else {
                        NSString *userID = me.ID;
                        NSString *userEmail = me.account.email;
                        
                        NSMutableDictionary *info = [NSMutableDictionary new];
                        info[@"status"] = @"loggedIn";
                        if (userID) {
                            info[@"userID"] = userID;
                        }
                        if (userEmail) {
                            info[@"userEmail"] = userEmail;
                        }
                        result(info);
                    }
                }];
            } else {
                // failed
                NSMutableDictionary *info = [NSMutableDictionary new];
                info[@"status"] = @"error";
                if (error) {
                    info[@"errorMessage"] = [error description];
                } else {
                    info[@"errorMessage"] = @"Unknown Error";
                }
                result(info);
            }
        } authType:(KOAuthType)KOAuthTypeTalk, nil];
    } else if ([@"logOut" isEqualToString:call.method]) {
        [[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error) {
            if (error) {
                result(@{ @"status" : @"error",
                          @"errorMessage" : [error description] });
            } else {
                result(@{ @"status" : @"loggedOut" });
            }
        }];
    } else if ([@"getUserMe" isEqualToString:call.method]) {
		[KOSessionTask userMeTaskWithPropertyKeys:@[@"kakao_account.email"
													, @"properties.nickname"
													, @"properties.profile_image"
													, @"properties.thumbnail_image"]
									   completion:^(NSError *error, KOUserMe *me) {
										   if (error) {
											   result(@{ @"status" : @"error",
														 @"errorMessage" : [error description] });
										   } else {
											   NSString *userID = me.ID;
											   NSString *userEmail = me.account.email;
											   NSString *userNickname = me.properties[@"nickname"];
											   NSString *userProfileImagePath = me.properties[@"profile_image"];
											   NSString *userThumbnailImagePath = me.properties[@"thumbnail_image"];
											   NSString *userPhoneNumber = me.account.phoneNumber;
											   NSString *userDisplayID = me.account.displayID;
											   NSString *userGender = @"";
											   KOUserGender gender = me.account.gender;
											   switch (gender) {
												   case KOUserGenderNull: {
													   userGender = @"";
													   break;
												   }
												   case KOUserGenderMale: {
													   userGender = @"MALE";
													   break;
												   }
												   case KOUserGenderFemale: {
													   userGender = @"FEMALE";
													   break;
												   }
												   default:
													   break;
											   }
											   NSString *userAgeRange = @"";
											   KOUserAgeRange ageRange = me.account.ageRange;
											   switch (ageRange) {
												   case KOUserAgeRangeNull: {
													   userAgeRange = @"";
													   break;
												   }
												   case KOUserAgeRangeType0: {
													   userAgeRange = @"0세~9세";
													   break;
												   }
												   case KOUserAgeRangeType10: {
													   userAgeRange = @"10세~14세";
													   break;
												   }
												   case KOUserAgeRangeType15: {
													   userAgeRange = @"15세~19세";
													   break;
												   }
												   case KOUserAgeRangeType20: {
													   userAgeRange = @"20세~29세";
													   break;
												   }
												   case KOUserAgeRangeType30: {
													   userAgeRange = @"30세~39세";
													   break;
												   }
												   case KOUserAgeRangeType40: {
													   userAgeRange = @"40세~49세";
													   break;
												   }
												   case KOUserAgeRangeType50: {
													   userAgeRange = @"50세~59세";
													   break;
												   }
												   case KOUserAgeRangeType60: {
													   userAgeRange = @"60세~69세";
													   break;
												   }
												   case KOUserAgeRangeType70: {
													   userAgeRange = @"70세~79세";
													   break;
												   }
												   case KOUserAgeRangeType80: {
													   userAgeRange = @"80세~89세";
													   break;
												   }
												   case KOUserAgeRangeType90: {
													   userAgeRange = @"90세 이상";
													   break;
												   }
												 default:
													 break;
											   }
											   NSString *userBirthday = me.account.birthday;
											   
											   NSMutableDictionary *info = [NSMutableDictionary new];
											   info[@"status"] = @"loggedIn";
											   if (userID) {
												   info[@"userID"] = userID;
											   }
											   if (userNickname) {
												   info[@"userNickname"] = userNickname;
											   }
											   if (userProfileImagePath) {
												   info[@"userProfileImagePath"] = userProfileImagePath;
											   }
											   if (userThumbnailImagePath) {
												   info[@"userThumbnailImagePath"] = userThumbnailImagePath;
											   }
											   if (userEmail) {
												   info[@"userEmail"] = userEmail;
											   }
											   if (userPhoneNumber) {
												   info[@"userPhoneNumber"] = userPhoneNumber;
											   }
											   if (userDisplayID) {
												   info[@"userDisplayID"] = userDisplayID;
											   }
											   if (userGender) {
												   info[@"userGender"] = userGender;
											   }
											   if (userAgeRange) {
												   info[@"userAgeRange"] = userAgeRange;
											   }
											   if (userBirthday) {
												   info[@"userBirthday"] = userBirthday;
											   }
											   result(info);
										   }
									   }];
    } else if ([@"getCurrentAccessToken" isEqualToString:call.method]) {
        NSString *accessToken = [KOSession sharedSession].token.accessToken;
        result(accessToken);
    } else if ([@"unlink" isEqualToString:call.method]) {
        [KOSessionTask unlinkTaskWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                // success
                result(@{ @"status" : @"unlikned" });
            } else {
                if (error) {
                    result([FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", error.code]
                                               message:error.domain
                                               details:error.localizedDescription]);
                } else {
                    result(nil);
                }
            }
        }];
    } else {
        result(FlutterMethodNotImplemented);
    }
}
    


#pragma mark -

- (instancetype)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 토큰 주기적 갱신
    // 로그인을 통해 얻은 사용자 토큰을 자동으로 주기적 갱신하는 기능입니다. 다른 API 사용 없이 오직 로그인만을 사용하는 앱일 경우, 사용자 토큰의 만료에 대한 걱정없이 SDK 내부적으로 해당 토큰을 자동 주기적으로 갱신합니다.
    [KOSession sharedSession].automaticPeriodicRefresh = YES;
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [KOSession handleDidEnterBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleWithUrl:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleWithUrl:url];
}

- (BOOL)handleWithUrl:(NSURL *)url {
    if ([KOSession isKakaoAccountLoginCallback:url]) {
        return [KOSession handleOpenURL:url];
    }
    return NO;
}

@end
