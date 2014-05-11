//
//  LPDataStore.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LPDataStore : NSObject

- (id)initWithToken:(NSString *)token;

// Location
- (void)registerEvent:(NSString *)event withBeacon:(CLBeacon *)beacon atTime:(NSDate *)createdAt;
- (void)registerEvent:(NSString *)event withBeaconRegion:(CLBeaconRegion *)region atTime:(NSDate *)createdAt;

@end
