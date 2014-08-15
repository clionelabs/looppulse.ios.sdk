//
//  LPBeaconRegionManager.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LPBeaconRegionManager : NSObject

// Both #regionsToMonitor returns list of regions which is sorted by
// the most important to least, i.e.,
// Give preference to monitor regionsToMonitor[0] over regionsToMonitor[10]
- (NSArray *)regionsToMonitor:(CLBeaconRegion *)enteredRegion;
- (NSArray *)regionsToNotMonitor:(CLBeaconRegion *)exitedRegion;

@end
