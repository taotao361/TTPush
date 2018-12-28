//
//  TTExchangeClass.h
//  TTNotification
//
//  Created by yxt on 2018/11/27.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@protocol TTPushManagerDelegate <NSObject>
@optional
- (void)applicationManager_deviceToken:(NSString *)token;
- (void)applicationManager_registerFailed:(NSError *)error;

//iOS10以下，当1、APP处于前台时调用 2、APP处于后台，点击push弹窗调用
- (void)applicationManager_didReceiveNotification:(NSDictionary *)userInfo analysisModel:(id)model;

//iOS10以上版本
//push弹窗将要展示的时候调用
- (void)applicationManager_willPresentNotification:(NSDictionary *)userInfo analysisModel:(id)model;
//APP处于前台 或 后台，点击push弹窗调用
- (void)applicationManager_didTouchForegroundNotification:(NSDictionary *)userInfo analysisModel:(id)model;

@end


@interface TTPushManager : NSObject

@property (nonatomic, weak) id <TTPushManagerDelegate> delegate;

/**
 * model name
 */
@property (nonatomic, assign, readonly) Class modelClass;

/**
 * 解析 key 默认为 @"extra"
 */
@property (nonatomic, copy, readonly) NSString *analysisKey;

/**
 * 根据 modelClass 解析后的model
 */
@property (nonatomic, strong, readonly) id analysisModel;

/**
 * deviceToken
 */
@property (nonatomic, copy, readonly) NSString *deviceToken;

/**
 * 根据pushMsgIdKey 解析出来的 value
 */
@property (nonatomic, copy, readonly) NSString *pushMsgId;

/**
 * 解析推送到达使用的key
 */
@property (nonatomic, copy, readonly) NSString *pushMsgIdKey;

+ (instancetype)shareInstance;

/**
 注册
 @param delagate 代理 不可为空
 */
- (void)registerRemoteNotification:(nonnull id<UIApplicationDelegate,UNUserNotificationCenterDelegate>)delagate;

/**
 @param modelClass 想要解析成哪种模型，modelClass
 @param analysisKey 解析model key
 @param pushIdKey 解析推送到达使用的key
 */
- (void)registerModelName:(nullable Class)modelClass analysisKey:(nullable NSString *)analysisKey pushMsgIdKey:(nullable NSString *)pushIdKey;

/**
 推送统计 iOS10以上版本 可在 push service extension h中使用
 @param msgID msgID
 @param token token
 */
+ (void)uploadPushMsgId:(NSString *)msgID token:(NSString *)token;

@end


/*
{
    "aps": {
        "alert": {
            "body": "body",
            "subtitle": "subtitle---",
            "title": "title"
        },
        "badge": 1,
        "extra": {//自定义objc
            "messageId": "123412424",
            "mid": "509086721601",
            "id": "10125090601793",
            "url": "http://www.baidu.com",
            "userId": "9520840333182"
        },
        "mutable-content": "1",
        "sound": "default",
        "pushId": 1111111111
    }
}
 
*/
