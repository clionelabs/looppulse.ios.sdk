//
//  LoopPulse.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"
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
@property (readonly, weak) UIApplication *application;

@end

@interface LPVisitor ()
- (id)initWithDataStore:(LPDataStore *)dataStore;
@end

@implementation LoopPulse

- (id)initWithToken:(NSString *)token withApplication:(UIApplication *)application
{
    self = [super init];
    if (self) {
        _token = token;
        _application = application;
        _firebaseBaseUrl = @"https://looppulse-megabox.firebaseio.com";
        _dataStore = [[LPDataStore alloc] initWithToken:token baseUrl:_firebaseBaseUrl];
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
        _locationManager.delegate = _locationManager;
        _engagementManager = [[LPEngagementManager alloc] initWithDataStore:_dataStore];

        // We may need the LPVisitor object when writing data.
        _dataStore.visitor = _visitor;

        // TODO: we may want to pass these keys to LPEngagementManager as
        // these are the only engagement related calls outside.
        [Parse setApplicationId:@"dP9yJQI58giCirVVIYeVd1YobFbIujv5wDFWA8WX"
                      clientKey:@"hnz5gkWZ45cJkXf8yp2huHc89NG55O1ajjHSrwxh"];
    }
    return self;
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


@end
