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

@interface LoopPulse ()
@property (readonly, retain) NSString *token;
@property (readonly, retain) LPDataStore *dataStore;
@property (readonly, retain) LPVisitor *visitor;
@property (readonly, retain) LPLocationManager *locationManager;
@end

@implementation LoopPulse

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
        _dataStore = [[LPDataStore alloc] initWithToken:token];
        _visitor = [[LPVisitor alloc] initWithDataStore:_dataStore];
        _locationManager = [[LPLocationManager alloc] initWithDataStore:_dataStore];
        _locationManager.delegate = _locationManager;

        // We may need the LPVisitor object when writing data.
        _dataStore.visitor = _visitor;
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
