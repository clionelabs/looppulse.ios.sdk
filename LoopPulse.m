//
//  LoopPulse.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"
#import "LPUser.h"
#import "LPLocationManager.h"
#import "LPDataStore.h"

@interface LoopPulse ()
@property (readonly, retain) NSString *token;
@property (readonly, retain) LPDataStore *dataStore;
@property (readonly, retain) LPUser *user;
@property (readonly, retain) LPLocationManager *locationManager;
@end

@implementation LoopPulse

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
        _dataStore = [[LPDataStore alloc] initWithToken:token];
        _user = [[LPUser alloc] init];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:self.dataStore];
        _locationManager.delegate = _locationManager;
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


@end
