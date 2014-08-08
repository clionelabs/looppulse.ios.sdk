//
//  LPEngagementManager.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDataStore.h"

@interface LPEngagementManager : NSObject

- (id)initWithDataStore:(LPDataStore *)dataStore;
- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
