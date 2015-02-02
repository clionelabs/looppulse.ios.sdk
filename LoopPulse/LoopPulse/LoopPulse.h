//
//  LoopPulse.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopPulse : NSObject

+ (LoopPulse *)sharedInstance;
+ (NSString *)version;

+ (void)setApplicationId:(NSString *)applicationId withToken:(NSString *)token;
+ (void)authenticate:(void (^)(NSError *error))completionHandler;
+ (BOOL)isAuthenticated;
+ (void)startLocationMonitoring;
+ (void)stopLocationMonitoring;
+ (void)identifyVisitorWithExternalId:(NSString *)externalId;
+ (void)tagVisitorWithProperities:(NSDictionary *)properties;

+ (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application;
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings withApplication:(UIApplication *)application;

- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties;

@property (readonly, nonatomic) BOOL isAuthorized; // to track location
@property (readonly, nonatomic) BOOL isTracking;
@property (readonly, nonatomic) NSUUID *visitorUUID;

extern NSString *const LoopPulseLocationAuthorizationGrantedNotification;
extern NSString *const LoopPulseLocationAuthorizationDeniedNotification;
extern NSString *const LoopPulseLocationDidEnterRegionNotification;
extern NSString *const LoopPulseLocationDidExitRegionNotification;

@end
