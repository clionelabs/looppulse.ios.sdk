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

- (id)initWithApplicationId:(NSString *)applicationId withToken:(NSString *)token;
- (void)authenticate:(void(^)(void))successHandler;

- (void)startLocationMonitoring;
- (void)stopLocationMonitoringAndRanging;

- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@property (readonly, nonatomic) BOOL isAuthenticated;

extern NSString *const LoopPulseDidAuthenticateSuccessfullyNotification;
extern NSString *const LoopPulseDidFailToAuthenticateNotification;
extern NSString *const LoopPulseLocationDidEnterRegionNotification;
extern NSString *const LoopPulseLocationDidExitRegionNotification;

- (void)startLocationMonitoringAndRanging; // debug

@property (readonly, nonatomic) NSUUID *visitorUUID;

@end
