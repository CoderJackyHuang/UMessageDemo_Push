//
//  HYBUMessageHelper.m
//  UMessageDemo
//
//  Created by 黄仪标 on 14/11/20.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import "HYBUMessageHelper.h"
#import "UMessage.h"
#include <objc/runtime.h>

#define kUMessageAppKey @"546d9a53fd98c533600016bb"

// ios 8.0 以后可用，这个参数要求指定为固定值
#define kCategoryIdentifier @"xiaoyaor"

@interface HYBUMessageHelper ()

@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation HYBUMessageHelper

+ (HYBUMessageHelper *)shared {
  static HYBUMessageHelper *sharedObject = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!sharedObject) {
      sharedObject = [[[self class] alloc] init];
    }
  });
  
  return sharedObject;
}

+ (void)startWithLaunchOptions:(NSDictionary *)launchOptions {
  // set AppKey and LaunchOptions
  [UMessage startWithAppkey:kUMessageAppKey launchOptions:launchOptions];
  
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
  if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    // register remoteNotification types
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"action1_identifier";
    action1.title=@"Accept";
    action1.activationMode = UIUserNotificationActivationModeForeground;// 当点击的时候启动程序
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  // 第二按钮
    action2.identifier = @"action2_identifier";
    action2.title = @"Reject";
    action2.activationMode = UIUserNotificationActivationModeBackground;// 当点击的时候不启动程序，在后台处理
    // 需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    action2.authenticationRequired = YES;
    action2.destructive = YES;
    
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = kCategoryIdentifier;// 这组动作的唯一标示
    [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge
    | UIUserNotificationTypeSound
    | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:[NSSet setWithObject:categorys]];
    
    [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
  } else {
    // register remoteNotification types
    UIRemoteNotificationType types = UIRemoteNotificationTypeBadge
    | UIRemoteNotificationTypeSound
    | UIRemoteNotificationTypeAlert;
    
    [UMessage registerForRemoteNotificationTypes:types];
  }
#else
  // iOS8.0之前使用此注册
  // register remoteNotification types
  UIRemoteNotificationType types = UIRemoteNotificationTypeBadge
  | UIRemoteNotificationTypeSound
  | UIRemoteNotificationTypeAlert;
  
  [UMessage registerForRemoteNotificationTypes:types];
#endif
  
#if DEBUG
  [UMessage setLogEnabled:YES];
#else
  [UMessage setLogEnabled:NO];
#endif
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
  [UMessage registerDeviceToken:deviceToken];
  return;
}

+ (void)unregisterRemoteNotifications {
  [UMessage unregisterForRemoteNotifications];
  return;
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [UMessage didReceiveRemoteNotification:userInfo];
  return;
}

+ (void)setAutoAlertView:(BOOL)shouldShow {
  [UMessage setAutoAlert:shouldShow];
  return;
}

+ (void)showCustomAlertViewWithUserInfo:(NSDictionary *)userInfo {
  [HYBUMessageHelper shared].userInfo = userInfo;
  
  // 应用当前处于前台时，需要手动处理
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [UMessage setAutoAlert:NO];
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送消息"
                                                          message:userInfo[@"aps"][@"alert"]
                                                         delegate:[HYBUMessageHelper shared]
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定", nil];
      [alertView show];
    });
  }
  return;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    // 如果不调用此方法，统计数据会拿不到，但是如果调用此方法，会再弹一次友盟定制的alertview显示推送消息
    // 所以这里根据需要来处理是否屏掉此功能
    [UMessage sendClickReportForRemoteNotification:[HYBUMessageHelper shared].userInfo];
  }
  return;
}

@end
