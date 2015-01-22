//
//  LoopPulse.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"
#import "LoopPulsePrivate.h"
#import "LPVisitor.h"
#import "LPLocationManager.h"
#import "LPDataStore.h"
#import "LPServerResponse.h"
#import "NSDictionary+LoopPulseHelpers.h"
#import "LPAuthManager.h"
#import <Parse/Parse.h>
#import <AdSupport/AdSupport.h>

@interface LoopPulse ()
@property (readonly, strong) NSString *applicationId;
@property (readonly, strong) NSString *token;
@property (readonly, strong) LPAuthManager *authManager;
@property (readonly, strong) LPDataStore *dataStore;
@property (readonly, strong) LPVisitor *visitor;
@property (readonly, strong) LPLocationManager *locationManager;
@property (readonly, strong) NSString *firebaseBaseUrl;
@end

@interface LPVisitor ()
- (id)initWithDataStore:(LPDataStore *)dataStore;
@end

NSString *const LoopPulseLocationAuthorizationGrantedNotification=@"LoopPulseLocationAuthorizationGrantedNotification";
NSString *const LoopPulseLocationAuthorizationDeniedNotification=@"LoopPulseLocationAuthorizationDeniedNotification";
NSString *const LoopPulseLocationDidEnterRegionNotification=@"LoopPulseLocationDidEnterRegionNotification";
NSString *const LoopPulseLocationDidExitRegionNotification=@"LoopPulseLocationDidExitRegionNotification";

@implementation LoopPulse
@synthesize visitorUUID = _visitorUUID;

- (id)init
{
    self = [super init];
    if (self) {
        ASIdentifierManager *adManager = [ASIdentifierManager sharedManager];
        _visitorUUID = adManager.advertisingIdentifier;
        _isTracking = adManager.advertisingTrackingEnabled;
    }
    return self;
}

/*
 * This function is supposed to be called by client app everytime on didFinishLaunchingWithOptions
 */
- (void)setApplicationId:(NSString *)applicationId andToken:(NSString *)token
{
    _applicationId = applicationId;
    _token = token;
    _authManager = [[LPAuthManager alloc] initWithApplicadtionId:applicationId andToken:token andVisitorUUID:[_visitorUUID UUIDString]];

    // If the client app has been authenticated before, then we have to make sure two things:
    //   i) check whether the authentication has expired (i.e. need to re-authenticate)
    //      To expire the previous authentication as to refresh the cached response data (e.g. poi list)
    //   ii) check wehther looppulse components (e.g. dataStore) has been initialized
    //      It could happen if the app was killed by system.
    if ([_authManager isAuthenticated]) {
        if ([_authManager isAuthenticationExpired]) {
            [_authManager authenticate:^(NSError *error) {
                if (error == nil) {
                    [self initComponents:^{}];
                }
            }];
        } else if (!_isComponentsInitialized){
            [self initComponents:^{}];
        }
    }
}

- (void)authenticate:(void (^)(NSError *error))completionHandler
{
    // If looppulse has been authenticated before, then we skip the authentication and simply call the completionHandler right away.
    // Maybe we should still do the authentication, since the client app explicitly ask?
    if ([_authManager isAuthenticated]) {
        completionHandler(nil);
        return;
    }

    // Authenticate
    [_authManager authenticate:^(NSError *error) {
        if (error != nil) {
            completionHandler(error);
        } else {
            [self initComponents:^{
                completionHandler(nil);
            }];
        }
    }];
}

- (void)startLocationMonitoring
{
    if (![_authManager isAuthenticated]) {
        @throw([self notAuthenticatedException]);
    }

    if (self.isTracking) {
        [self.locationManager startMonitoringForAllRegions];
    }
}

- (void)stopLocationMonitoring
{
    if (![_authManager isAuthenticated]) {
        @throw([self notAuthenticatedException]);
    }
    [self.locationManager stopMonitoringForAllRegions];
}

- (void)initComponents:(void (^)(void))completionHandler
{
    if (![_authManager isAuthenticated]) {
        @throw([self notAuthenticatedException]);
    }

    _captureId = [[LoopPulse defaults] objectForKey:@"captureId"];
    _dataStore = [[LPDataStore alloc] initWithFirebaseConfig:[[LoopPulse defaults] objectForKey:@"firebase"]];
    [_dataStore authenticateFirebase:^(void){
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
        _isComponentsInitialized = YES;
        completionHandler();
    }];
}

- (NSException *)notAuthenticatedException
{
    return [NSException
            exceptionWithName:@"NotAuthenticatedException"
            reason:@"LoopPulse has not yet been authenticated"
            userInfo:nil];
}

- (BOOL)isAuthorized
{
    return [self.locationManager isAuthorized];
}

- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties {
    [self.visitor track:eventName WithProperties:properties];
}

#pragma mark Public Interface

+ (NSString *)version
{
    return @"0.5";
}

+ (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application
{
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
}

+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings withApplication:(UIApplication *)application
{
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
}

+ (void)setApplicationId:(NSString *)applicationId withToken:(NSString *)token
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse setApplicationId:applicationId andToken:token];
}

+ (void)authenticate:(void (^)(NSError *error))completionHandler
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse authenticate:completionHandler];
}

+ (void)startLocationMonitoring
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse startLocationMonitoring];
}

+ (void)stopLocationMonitoring
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse stopLocationMonitoring];
}

+ (void)identifyVisitorWithExternalId:(NSString *)externalId
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.visitor identifyWithExternalID:externalId];
}

+ (void)tagVisitorWithProperities:(NSDictionary *)properties
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.visitor tagWithProperties:properties];
}

+ (BOOL)isAuthenticated
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    return [loopPulse.authManager isAuthenticated];
}

#pragma mark Private Class Methods

+ (LoopPulse *)sharedInstance
{
    static LoopPulse *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

+ (void)postNotification:(NSString *)name withUserInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:[LoopPulse sharedInstance]
                                                      userInfo:userInfo];
    NSLog(@"Loop Pulse posted %@ with userInfo: %@", name, userInfo);
}

@end
