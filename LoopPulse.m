//
//  LoopPulse.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"
#import "LPLocationManager.h"

@interface LoopPulse ()
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) LPLocationManager *locationManager;
@end

@implementation LoopPulse

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
        self.locationManager = [[LPLocationManager alloc] initWithToken:token];
        self.locationManager.delegate = self.locationManager;
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
