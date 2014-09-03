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
#import <Parse/Parse.h>

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

@implementation LoopPulse

- (id)initWithApplicationId:(NSString *)applicationId withToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _applicationId = applicationId;
        _token = token;
        _isAuthenticated = false;
    }
    return self;
}

- (void)authenticate:(void (^)(void))successHandler
{
    NSString *url = [@"http://beta.looppulse.com/api/authenticate/applications/" stringByAppendingString:self.applicationId];
    NSURL *authenticationURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authenticationURL];
    [request setValue:self.token forHTTPHeaderField:@"x-auth-token"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlResonse, NSData *data, NSError *error) {
                               if (error!=nil) {
                                   NSLog(@"authentication error: %@", error);
                               } else {
                                   LPServerResponse *response = [[LPServerResponse alloc] initWithData:data];
                                   if (response.isAuthenticated) {
                                       _isAuthenticated = true;
                                       [self initFromDefaults:response.defaults];

                                       successHandler();
                                   }
                               }
                           }];
}

- (void)initFromDefaults:(NSDictionary *)defaults
{
    [self setDefaults:defaults];

    _dataStore = [[LPDataStore alloc] initWithToken:self.token
                                            andURLs:[self firebaseURLs]];
    _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
    _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
    _engagementManager = [[LPEngagementManager alloc] initWithDataStore:_dataStore];
}

// Set defaults from server response
- (void)setDefaults:(NSDictionary *)response
{
    NSDictionary *system = [response objectForKey:@"system"];
    BOOL onlySendKnown = [[system objectForKey:@"onlySendBeaconEventsWithKnownProximity"] boolValue];
    [LoopPulse.defaults setBool:onlySendKnown
                         forKey:@"onlySendBeaconEventsWithKnownProximity"];

    NSString *urlString = [system objectForKey:@"configurationJSON"];
    NSURL *configurationJSON = [NSURL URLWithString:urlString];
    [LoopPulse.defaults setURL:configurationJSON
                        forKey:@"configurationJSON"];

    NSDictionary *firebaseDefaults = [system objectForKey:@"firebase"];
    [LoopPulse.defaults setObject:firebaseDefaults forKey:@"firebase"];

    NSDictionary *parseDefaults = [system objectForKey:@"parse"];
    [LoopPulse.defaults setObject:parseDefaults forKey:@"parse"];

    [LoopPulse.defaults synchronize];
}

- (NSDictionary *)firebaseURLs
{
    return [[LoopPulse defaults] objectForKey:@"firebase"];
}

- (void)startLocationMonitoring
{
    [self.locationManager startMonitoringForAllRegions];
}

- (void)stopLocationMonitoringAndRanging
{
    [self.locationManager stopRangingBeaconsInAllRegions];
    [self.locationManager stopMonitoringForAllRegions];
}


- (void)registerForRemoteNotificationTypesForApplication:(UIApplication *)application
{
    [self.engagementManager registerForRemoteNotificationTypesForApplication:application];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.engagementManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.engagementManager didReceiveRemoteNotification:userInfo];
}


- (void)startLocationMonitoringAndRanging
{
    [self.locationManager startMonitoringForAllRegions];
    [self.locationManager startRangingBeaconsInAllRegions];
}

- (NSUUID *)visitorUUID
{
    return [self.dataStore visitorUUID];
}


#pragma mark Private Class Methods

+ (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end
