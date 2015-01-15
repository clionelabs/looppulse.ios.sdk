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
#import "LPEngagementManager.h"
#import "LPServerResponse.h"
#import "NSDictionary+LoopPulseHelpers.h"
#import <Parse/Parse.h>
#import <AdSupport/AdSupport.h>

@interface LoopPulse ()
@property (readonly, strong) NSString *applicationId;
@property (readonly, strong) NSString *token;
@property (readonly, strong) LPDataStore *dataStore;
@property (readonly, strong) LPVisitor *visitor;
@property (readonly, strong) LPLocationManager *locationManager;
@property (readonly, strong) LPEngagementManager *engagementManager;
@property (readonly, strong) NSString *firebaseBaseUrl;
@end

@interface LPVisitor ()
- (id)initWithDataStore:(LPDataStore *)dataStore;
@end

NSString *const LoopPulseDidAuthenticateSuccessfullyNotification=@"LoopPulseDidAuthenticateSuccessfullyNotification";
NSString *const LoopPulseDidFailToAuthenticateNotification=@"LoopPulseDidFailToAuthenticateNotification";
NSString *const LoopPulseDidReceiveAuthenticationError=@"LoopPulseDidReceiveAuthenticationError";
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
        _isAuthenticated = false;

        ASIdentifierManager *adManager = [ASIdentifierManager sharedManager];
        _visitorUUID = adManager.advertisingIdentifier;
        _isTracking = adManager.advertisingTrackingEnabled;
    }
    return self;
}

- (void)setApplicationId:(NSString *)applicationId andToken:(NSString *)token
{
    _applicationId = applicationId;
    _token = token;
}

- (NSDictionary *)authenticationPayload
{
    // sdk
    NSDictionary *sdk = @{@"version": [LoopPulse version]};

    // device
    // https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/index.html#//apple_ref/occ/instp/UIDevice/name
    UIDevice *uiDevice = [UIDevice currentDevice];
    NSDictionary *device = @{@"model": [uiDevice model],
                             @"systemVersion": [uiDevice systemVersion]};

    NSDictionary *payload = @{@"visitorUUID": [[[LoopPulse sharedInstance] visitorUUID] UUIDString],
                              @"sdk": sdk,
                              @"device": device};
    return payload;
}

- (NSURLRequest *)authenticationRequest
{
//    NSString *url = [@"http://beta.looppulse.com/api/authenticate/applications/" stringByAppendingString:self.applicationId];
//    NSString *url = [@"http://localhost:3000/api/authenticate/applications/" stringByAppendingString:self.applicationId];
    NSString *url = [@"http://192.168.0.102:3000/api/authenticate/applications/" stringByAppendingString:self.applicationId];
//    NSString *url = [@"https://ouuyckfgsv.localtunnel.me/api/authenticate/applications/" stringByAppendingString:self.applicationId];

    NSURL *authenticationURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authenticationURL];
    [request setValue:self.token forHTTPHeaderField:@"x-auth-token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *jsonString = [[self authenticationPayload] jsonString:@"capture"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    return request;
}

- (void)authenticate:(void (^)(void))successHandler
{
    NSURLRequest *request = [self authenticationRequest];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlResonse, NSData *data, NSError *error) {

                               if (error!=nil) {
                                   NSDictionary *userInfo = @{@"applicationId": self.applicationId, @"error":error};
                                   [LoopPulse postNotification:LoopPulseDidReceiveAuthenticationError withUserInfo:userInfo];

                               } else {
                                   NSDictionary *userInfo = @{@"applicationId": self.applicationId};
                                   LPServerResponse *response = [[LPServerResponse alloc] initWithData:data];
                                   if (response.isAuthenticated) {
                                       [self initFromServerResponse:response withSuccessBlock:^(void){
                                           _isAuthenticated = true;
                                           _captureId = response.captureId;
                                           [LoopPulse postNotification:LoopPulseDidAuthenticateSuccessfullyNotification withUserInfo:userInfo];

                                           successHandler();
                                       }];
                                   } else {
                                       [LoopPulse postNotification:LoopPulseDidFailToAuthenticateNotification withUserInfo:userInfo];
                                   }
                               }
                           }];
}

- (void)initFromServerResponse:(LPServerResponse *)response withSuccessBlock:(void (^)(void))successBlock
{
    NSLog(@"updating system configuration: %@", response.systemConfiguration);
    // TODO: we should phase out the use of NSDefaults and directly set corresponsding properties:
    [self setDefaults:response.systemConfiguration];

    _dataStore = [[LPDataStore alloc] initWithFirebaseConfig:[self firebaseConfig]];
    [_dataStore authenticateFirebase:^(void){
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
//        _engagementManager = [[LPEngagementManager alloc] initWithDataStore:_dataStore];
        successBlock();
    }];
}

// Set defaults from server response
- (void)setDefaults:(NSDictionary *)system
{
    BOOL onlySendKnown = [[system objectForKey:@"onlySendBeaconEventsWithKnownProximity"] boolValue];
    [LoopPulse.defaults setBool:onlySendKnown
                         forKey:@"onlySendBeaconEventsWithKnownProximity"];

    NSDictionary *firebaseDefaults = [system objectForKey:@"firebase"];
    [LoopPulse.defaults setObject:firebaseDefaults forKey:@"firebase"];

    NSDictionary *poisDefaults = [system objectForKey:@"pois"];
    [LoopPulse.defaults setObject:poisDefaults forKey:@"pois"];

//    NSDictionary *parseDefaults = [system objectForKey:@"parse"];
//    [LoopPulse.defaults setObject:parseDefaults forKey:@"parse"];

    [LoopPulse.defaults synchronize];
}

- (NSDictionary *)firebaseConfig
{
    return [[LoopPulse defaults] objectForKey:@"firebase"];
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

+ (void)authenticateWithApplicationId:(NSString *)applicationId
                            withToken:(NSString *)token
                    andSuccessHandler:(void(^)(void))successHandler
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse setApplicationId:applicationId andToken:token];
    [loopPulse authenticate:successHandler];
}

+ (void)startLocationMonitoring
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    if (loopPulse.isTracking) {
        [loopPulse.locationManager startMonitoringForAllRegions];
    } else {
        // Respect advertisingTrackingEnabled and stop all tracking.
        [loopPulse.locationManager stopMonitoringForAllRegions];
    }
}

+ (void)stopLocationMonitoring {
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.locationManager stopMonitoringForAllRegions];
}

+ (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.engagementManager registerForRemoteNotificationTypesForApplication:application];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.engagementManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings withApplication:(UIApplication *)application
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.engagementManager didRegisterUserNotificationSettings:notificationSettings withApplication:application];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    LoopPulse *loopPulse = [LoopPulse sharedInstance];
    [loopPulse.engagementManager didReceiveRemoteNotification:userInfo];
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
