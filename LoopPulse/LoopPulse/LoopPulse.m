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

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        [self setDefaults];

        _token = token;
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _firebaseBaseUrl = @"https://looppulse-megabox.firebaseio.com";
        _dataStore = [[LPDataStore alloc] initWithToken:token baseUrl:_firebaseBaseUrl andVisitor:_visitor];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
        _engagementManager = [[LPEngagementManager alloc] initWithDataStore:_dataStore];

        // TODO: we may want to pass these keys to LPEngagementManager as
        // these are the only engagement related calls outside.
        [Parse setApplicationId:@"dP9yJQI58giCirVVIYeVd1YobFbIujv5wDFWA8WX"
                      clientKey:@"hnz5gkWZ45cJkXf8yp2huHc89NG55O1ajjHSrwxh"];


    }
    return self;
}

// Create and set user defaults
- (void)setDefaults
{
    [LoopPulse.defaults setBool:false
                         forKey:@"onlySendBeaconEventsWithKnownProximity"];

    // TODO: Get these from Loop Pulse server
    NSURL *configurationURL = [NSURL URLWithString:@"https://looppulse-config.firebaseio.com/companies/-JUw0gTrsmeSBsbqeGif.json"];
    [LoopPulse.defaults setURL:configurationURL
                        forKey:@"configurationURL"];

    [LoopPulse.defaults synchronize];
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
