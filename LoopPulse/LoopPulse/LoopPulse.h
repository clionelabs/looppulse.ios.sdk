//
//  LoopPulse.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPVisitor.h"

@interface LoopPulse : NSObject

- (id)initWithToken:(NSString*)token withApplication:(UIApplication *)application;

- (void)startLocationMonitoring;
- (void)stopLocationMonitoringAndRanging;

- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)startLocationMonitoringAndRanging; // debug

@property (readonly, retain) LPVisitor *visitor;

@end
