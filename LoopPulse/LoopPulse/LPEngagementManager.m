//
//  LPEngagementManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagementManager.h"
#import "LPVisitor.h"
#import "LPDataStore+LPEngagementManager.h"
#import "LoopPulsePrivate.h"
#import <Parse/Parse.h>

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
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound];
}

- (NSString *)pushChannelName
{
    // Can't just use UUID beacause channel name can't start with a
    // https://github.com/clionelabs/looppulse.ios.sdk/issues/3#issuecomment-48022164
    return [@"VisitorUUID_" stringByAppendingString: [self.dataStore.visitorUUID UUIDString]];
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
    [PFPush handlePush:userInfo];
    [self.dataStore logEvent:@"didReceiveRemoteNotification" withEngagement:userInfo atTime:[NSDate date]];
}
@end
