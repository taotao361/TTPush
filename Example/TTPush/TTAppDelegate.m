//
//  TTAppDelegate.m
//  TTPush
//
//  Created by yangxutao361@163.com on 12/26/2018.
//  Copyright (c) 2018 yangxutao361@163.com. All rights reserved.
//

#import "TTAppDelegate.h"
#import <TTPush/TTPushManager.h>

@interface TTAppDelegate ()<TTPushManagerDelegate,UNUserNotificationCenterDelegate>

@end

@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[TTPushManager shareInstance] registerRemoteNotification:self];
    [TTPushManager shareInstance].delegate = self;
//    [[TTPushManager shareInstance] registerModelName:[xxx class] analysisKey:nil pushMsgIdKey:nil];

    
    return YES;
}

#pragma mark - TTPushManagerDelegate
- (void)applicationManager_deviceToken:(NSString *)token {
    NSLog(@"deviceToken = %@", token);
    if (token != nil) {//extension 使用文件共享来获取token
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xxx.app.group"];
        [defaults setObject:token forKey:@"deviceToken"];
        [defaults synchronize];
        //存储token
    }
}

- (void)applicationManager_registerFailed:(NSError *)error {
    NSLog(@"APNs注册失败------%@", error.userInfo);
}

- (void)applicationManager_didReceiveNotification:(NSDictionary *)userInfo analysisModel:(id)model {
    //处理跳转逻辑
    //iOS8 9 推送到达统计
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 10) {
        [TTPushManager uploadPushMsgId:[TTPushManager shareInstance].pushMsgId token:[TTPushManager shareInstance].deviceToken];
    }
}

- (void)applicationManager_willPresentNotification:(NSDictionary *)userInfo analysisModel:(id)model {
    //处理跳转逻辑
}

- (void)applicationManager_didTouchForegroundNotification:(NSDictionary *)userInfo analysisModel:(id)model {
    //处理跳转逻辑
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
