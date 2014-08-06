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

#define kDefaultFirebaseBaseUrl @"https://looppulse-dev.firebaseio.com"

@interface LoopPulse ()
@property (readonly, strong) NSString *token;
@property (readonly, strong) LPDataStore *dataStore;
@property (readonly, strong) LPLocationManager *locationManager;
@property (readonly, strong) NSString *firebaseBaseUrl;

@end

@interface LPVisitor ()
- (id)initWithDataStore:(LPDataStore *)dataStore;
@end

@implementation LoopPulse

- (id)initWithToken:(NSString *)token
{
    return [self initWithToken:token options:@{}];
}

- (id)initWithToken:(NSString *)token options:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        _token = token;
        _firebaseBaseUrl = options[@"baseUrl"] ? options[@"baseUrl"] : kDefaultFirebaseBaseUrl;
        _dataStore = [[LPDataStore alloc] initWithToken:token baseUrl:_firebaseBaseUrl];
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

- (NSArray *)availableNotifications{
    return @[@"didEnterRegion", @"didExitRegion", @"didRangeBeacons"];
}

- (void)startLocationMonitoringAndRanging
{
    [self.locationManager startMonitoringForAllRegions];
    [self.locationManager startRangingBeaconsInAllRegions];
}


@end
