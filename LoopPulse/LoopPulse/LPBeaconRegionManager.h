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

@property (nonatomic, readonly) NSArray *genericRegionsToMonitor;

@end
