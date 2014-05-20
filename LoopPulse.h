//
//  LoopPulse.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopPulse : NSObject

- (id)initWithToken:(NSString*)token;
- (void)startLocationMonitoring;
- (void)stopLocationMonitoringAndRanging;
- (NSArray *)availableNotifications;

- (void)startLocationMonitoringAndRanging; // debug
@end
