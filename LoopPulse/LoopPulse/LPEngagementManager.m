//
//  LPEngagementManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagementManager.h"
#import "LPDataStore+LPEngagementManager.h"
#import "LoopPulsePrivate.h"
#import <Parse/Parse.h>
#import "LPEngagementViewController.h"
#import "LPEngagement.h"

@interface LPEngagementManager ()
@property (nonatomic, retain) LPDataStore *dataStore;
@end

@implementation LPEngagementManager

- (id)initWithDataStore:(LPDataStore *)dataStore;
{
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        [self initPush];
    }
    return self;
}

- (void)initPush
{
    NSDictionary *parseDefaults = [LoopPulse.defaults objectForKey:@"parse"];
    NSString *applicationId = [parseDefaults objectForKey:@"applicationId"];
    NSString *clienKey = [parseDefaults objectForKey:@"clientKey"];

    [Parse setApplicationId:applicationId clientKey:clienKey];
}

- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) { // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
    else { // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}

- (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings withApplication:(UIApplication *)application
{
    [application registerForRemoteNotifications];
}

- (NSString *)pushChannelName
{
    // Can't just use UUID beacause channel name can't start with a
    // https://github.com/clionelabs/looppulse.ios.sdk/issues/3#issuecomment-48022164
    NSUUID *visitorUUID = [[LoopPulse sharedInstance] visitorUUID];
    return [@"VisitorUUID_" stringByAppendingString: [visitorUUID UUIDString]];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];

    [currentInstallation addUniqueObject:[self pushChannelName] forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    LPEngagement *engagement = [[LPEngagement alloc] initWithPushPayload:userInfo];
    [self presentEngagement:engagement];
}

- (void)logEngagement:(LPEngagement *)engagement
{
    [self.dataStore logEvent:@"didReceiveRemoteNotification"
              withEngagement:engagement
                      atTime:[NSDate date]];
}

- (void)presentEngagement:(LPEngagement *)engagement
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootVC = window.rootViewController;
    LPEngagementViewController *engagementVC = [[LPEngagementViewController alloc] initWithEngagement:engagement];
    [rootVC presentViewController:engagementVC
                         animated:YES
                       completion:^(void){
                           [self logEngagement:engagement];
                       }
     ];
}
@end
