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
#import <Parse/Parse.h>

@interface LoopPulse ()
@property (readonly, strong) NSString *applicationId;
@property (readonly, strong) NSString *token;
@property (readonly, strong) LPDataStore *dataStore;
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

        NSDictionary *response = [self authenticate:applicationId withToken:token];
        BOOL authenicated = [self isAuthenticated:response];
        // TODO: handle failed authentication more gracefully
        if (!authenicated) {
            return nil;
        }

        // Authenticated so we can set defaults from the response.
        [self setDefaults:response];

        _dataStore = [[LPDataStore alloc] initWithToken:token
                                                andURLs:[self firebaseURLs]];
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
        _engagementManager = [[LPEngagementManager alloc] initWithDataStore:_dataStore];
    }
    return self;
}

- (NSDictionary *)authenticate:(NSString *)applicationId withToken:(NSString *)token
{
    NSDictionary *response = @{@"authenticated":@true,
                               @"system":
                                   @{@"onlySendBeaconEventsWithKnownProximity":@false,
                                     @"configurationJSON":@"https://looppulse-config.firebaseio.com/companies/-JUw0gTrsmeSBsbqeGif.json",
                                     @"firebase":
                                         @{@"beacon_events": @"https://looppulse-megabox.firebaseio.com/companies/sY35Akn2TGaTnfmBX/beacon_events",
                                           @"engagement_events": @"https://looppulse-megabox.firebaseio.com/companies/sY35Akn2TGaTnfmBX/engagement_events"},
                                     @"parse":
                                         @{@"applicationId":@"dP9yJQI58giCirVVIYeVd1YobFbIujv5wDFWA8WX",
                                           @"clientKey":@"hnz5gkWZ45cJkXf8yp2huHc89NG55O1ajjHSrwxh"}
                                    }
                               };
    return response;
}

- (BOOL)isAuthenticated:(NSDictionary *)response
{
    BOOL authenticated = [[response objectForKey:@"authenticated"] boolValue];
    if (!authenticated) {
        return false;
    }
   return true;
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

#pragma mark Private Class Methods

+ (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

@end
