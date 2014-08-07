//
//  LPEngagementManager.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPVisitor.h"

@interface LPEngagementManager : NSObject

- (id)initWithVisitor:(LPVisitor *)visitor andApplication:(UIApplication *)application;
- (void)registerForRemoteNotificationTypes;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
