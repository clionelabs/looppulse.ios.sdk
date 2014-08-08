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
    }
    return self;
}

- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application
{
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];

    NSString *visitorUUID = [@"VisitorUUID_" stringByAppendingString: [self.dataStore.visitorUUID UUIDString]];
    [currentInstallation addUniqueObject:visitorUUID forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    [self.dataStore logEvent:@"engagementViewed" withEngagement:userInfo atTime:[NSDate date]];
}
@end
