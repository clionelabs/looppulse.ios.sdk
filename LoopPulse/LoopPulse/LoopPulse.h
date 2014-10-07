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

+ (LoopPulse *)sharedInstance;
+ (NSString *)version;

+ (void)authenticateWithApplicationId:(NSString *)applicationId
                            withToken:(NSString *)token
                    andSuccessHandler:(void(^)(void))successHandler;
+ (void)startLocationMonitoring;

+ (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application;
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

+ (void)identifyVisitorWithExternalId:(NSString *)externalId;

@property (readonly, nonatomic) BOOL isAuthenticated;
@property (readonly, nonatomic) BOOL isAuthorized; // to track location
@property (readonly, nonatomic) BOOL isTracking;
@property (readonly, nonatomic) NSUUID *visitorUUID;

extern NSString *const LoopPulseDidAuthenticateSuccessfullyNotification;
extern NSString *const LoopPulseDidFailToAuthenticateNotification;
extern NSString *const LoopPulseDidReceiveAuthenticationError;
extern NSString *const LoopPulseLocationAuthorizationGrantedNotification;
extern NSString *const LoopPulseLocationAuthorizationDeniedNotification;
extern NSString *const LoopPulseLocationDidEnterRegionNotification;
extern NSString *const LoopPulseLocationDidExitRegionNotification;

@end
