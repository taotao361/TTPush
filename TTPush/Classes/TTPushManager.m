//
//  TTExchangeClass.m
//  TTNotification
//
//  Created by yxt on 2018/11/27.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import "TTPushManager.h"
#import "NSObject+TTExchange.h"
#import <MJExtension/MJExtension.h>


@interface TTPushManager ()
@property (nonatomic, assign, readwrite) Class modelClass;
@property (nonatomic, copy, readwrite) NSString *analysisKey;
@property (nonatomic, copy, readwrite) NSString *pushMsgId;
@property (nonatomic, copy, readwrite) NSString *pushMsgIdKey;
@property (nonatomic, strong, readwrite) id analysisModel;
@property (nonatomic, copy, readwrite) NSString *deviceToken;
@end

@implementation TTPushManager

- (void)registerModelName:(nullable Class)modelClass analysisKey:(nullable NSString *)analysisKey pushMsgIdKey:(nullable NSString *)pushIdKey {
    if(analysisKey.length > 0) {
        [TTPushManager shareInstance].analysisKey = analysisKey;
    }
    if (modelClass) {
        [TTPushManager shareInstance].modelClass = modelClass;
    }
    if (pushIdKey.length > 0) {
        [TTPushManager shareInstance].pushMsgIdKey = pushIdKey;
    }
}

+ (instancetype)shareInstance {
    static TTPushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        instance.analysisKey = @"extra";//解析自己业务数据用到的key
        instance.pushMsgIdKey = @"msgId";//解析推送到达率使用的key
    });
    return instance;
}

- (void)exchangeMethod:(id)delegate {
    Class appDelegate = [delegate class];
    tt_swizzleMethodImplementation(appDelegate, [self class], @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), @selector(tt_application:didRegisterForRemoteNotificationsWithDeviceToken:));
    
    tt_swizzleMethodImplementation(appDelegate, [self class], @selector(application:didFailToRegisterForRemoteNotificationsWithError:), @selector(tt_application:didFailToRegisterForRemoteNotificationsWithError:));

    tt_swizzleMethodImplementation(appDelegate,[self class], @selector(application:didRegisterUserNotificationSettings:), @selector(tt_application:didRegisterUserNotificationSettings:));
    
//    tt_swizzleMethodImplementation(appDelegate, [self class], @selector(application:didReceiveRemoteNotification:), @selector(tt_application:didReceiveRemoteNotification:));
    
    tt_swizzleMethodImplementation(appDelegate,[self class], @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:), @selector(tt_application:didReceiveRemoteNotification:fetchCompletionHandler:));
    
    if (@available(iOS 10.0, *)) {
        tt_swizzleMethodImplementation(appDelegate,[self class], @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:), @selector(tt_userNotificationCenter:willPresentNotification:withCompletionHandler:));

        tt_swizzleMethodImplementation(appDelegate,[self class], @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:), @selector(tt_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:));
    }
}


- (void)tt_application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if ([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_deviceToken:)]) {
        NSString *token = [[TTPushManager shareInstance] deviceTokenStringWithData:deviceToken];
        [[TTPushManager shareInstance].delegate applicationManager_deviceToken:token];
        [TTPushManager shareInstance].deviceToken = token;
    }
}

- (void)tt_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_registerFailed:)]) {
        [[TTPushManager shareInstance].delegate applicationManager_registerFailed:error];
    }
}

- (void)tt_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_didReceiveNotification:analysisModel:)]) {
        [[TTPushManager shareInstance] analysisModel:userInfo];
        [[TTPushManager shareInstance].delegate applicationManager_didReceiveNotification:userInfo analysisModel:[TTPushManager shareInstance].analysisModel];
    }
}

- (void)tt_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_didReceiveNotification:analysisModel:)]) {
        [[TTPushManager shareInstance] analysisModel:userInfo];
        [[TTPushManager shareInstance].delegate applicationManager_didReceiveNotification:userInfo analysisModel:[TTPushManager shareInstance].analysisModel];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)tt_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

//应用在前台收到通知 系统弹窗
- (void)tt_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)) {
    if (@available(iOS 10.0, *)) {
        if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            NSDictionary *userInfo = notification.request.content.userInfo;
            if([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_willPresentNotification:analysisModel:)]) {
                [[TTPushManager shareInstance] analysisModel:userInfo];
                [[TTPushManager shareInstance].delegate applicationManager_willPresentNotification:userInfo analysisModel:[TTPushManager shareInstance].analysisModel];
            }
        }
    }
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

//  iOS10特性。点击通知进入App
- (void)tt_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    if (@available(iOS 10.0, *)) {
        if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            NSDictionary *userInfo = response.notification.request.content.userInfo;
            if([TTPushManager shareInstance].delegate && [[TTPushManager shareInstance].delegate respondsToSelector:@selector(applicationManager_didTouchForegroundNotification:analysisModel:)]) {
                [[TTPushManager shareInstance] analysisModel:userInfo];
                [[TTPushManager shareInstance].delegate applicationManager_didTouchForegroundNotification:userInfo analysisModel:[TTPushManager shareInstance].analysisModel];
            }
        }
    }
    completionHandler();
}

- (void)analysisModel:(NSDictionary *)userInfo {
    id model = nil;
    if ([TTPushManager shareInstance].analysisKey.length && [TTPushManager shareInstance].modelClass) {
        NSDictionary *dic = userInfo[@"aps"][[TTPushManager shareInstance].analysisKey];
        model = [[TTPushManager shareInstance].modelClass mj_objectWithKeyValues:dic];
        [TTPushManager shareInstance].analysisModel = model;
    }
    if ([TTPushManager shareInstance].pushMsgIdKey.length > 0) {
        id value = userInfo[@"aps"][[TTPushManager shareInstance].pushMsgIdKey];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [(NSNumber *)value stringValue];
        }
        [TTPushManager shareInstance].pushMsgId = value;
    }
}

#pragma mark -register
- (void)registerRemoteNotification:(id<UIApplicationDelegate,UNUserNotificationCenterDelegate>)delagate  API_AVAILABLE(ios(10.0)) {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeMethod:delagate];
    });
    
    UIApplication *application = [UIApplication sharedApplication];
    CGFloat sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion >= 10.0) {
        //iOS10特有
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = delagate;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    NSLog(@"remote notification 注册成功");
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        NSLog(@"%@", settings);
                    }];
                } else {
                    NSLog(@"注册失败");
                }
            }];
        }
    } else if (sysVersion > 8.0){
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
#pragma clang diagnostic pop
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (NSString *)deviceTokenStringWithData:(NSData *)deviceToken {
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@", deviceToken];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    return deviceTokenStr;
}

#pragma mark - upload msgID
//上报自己的推送到达统计接口
+ (void)uploadPushMsgId:(NSString *)msgID token:(NSString *)token {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@""]];
    request.HTTPMethod = @"POST";
    NSMutableString *bodyStr = @"".mutableCopy;
    if ([msgID isKindOfClass:[NSString class]] && msgID.length > 0) {
        [bodyStr appendString:[NSString stringWithFormat:@"msgID=%@",msgID]];
    }
    if ([msgID isKindOfClass:[NSString class]] && token.length > 0) {
        [bodyStr appendString:[NSString stringWithFormat:@"&token=%@",token]];
    }
    request.HTTPBody = [bodyStr.copy dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                NSLog(@"----- upload success = %@ ------",str);
                                            }];
    [task resume];
}



@end
