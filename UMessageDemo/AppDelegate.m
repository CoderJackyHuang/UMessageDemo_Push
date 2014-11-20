//
//  AppDelegate.m
//  UMessageDemo
//
//  Created by 黄仪标 on 14/11/20.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import "AppDelegate.h"
#import "HYBUMessageHelper.h"
#import "UMessage_Sdk_1.1.0/UMessage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  
  [HYBUMessageHelper startWithLaunchOptions:launchOptions];
  
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [HYBUMessageHelper registerDeviceToken:deviceToken];
  
  NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                stringByReplacingOccurrencesOfString: @">" withString: @""]
               stringByReplacingOccurrencesOfString: @" " withString: @""]);
  return;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [HYBUMessageHelper didReceiveRemoteNotification:userInfo];
  
  [HYBUMessageHelper setAutoAlertView:NO];
  return;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification
                   :(NSDictionary *)userInfo fetchCompletionHandler
                   :(void (^)(UIBackgroundFetchResult))completionHandler {
  [HYBUMessageHelper didReceiveRemoteNotification:userInfo];
  
  [HYBUMessageHelper setAutoAlertView:NO];
  completionHandler(UIBackgroundFetchResultNewData);
  return;
}

@end
