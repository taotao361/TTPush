//
//  NotificationService.m
//  TTPushExtension
//
//  Created by yxt on 2018/12/28.
//  Copyright © 2018年 yangxutao361@163.com. All rights reserved.
//

#import "NotificationService.h"
#import <TTPush/TTPushManager.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
//    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    //需要文件分享
    NSDictionary *userInfo = request.content.userInfo;
    NSString *msgID = userInfo[@"aps"][@"msgId"];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xxx.app.group"];
    NSString *token = [defaults objectForKey:@"deviceToken"];
    [TTPushManager uploadPushMsgId:msgID token:token];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
