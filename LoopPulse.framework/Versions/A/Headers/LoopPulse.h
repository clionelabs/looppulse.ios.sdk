//
//  LoopPulse.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPVisitor.h"

@interface LoopPulse : NSObject

- (id)initWithToken:(NSString*)token;
- (id)initWithToken:(NSString*)token options:(NSDictionary *)options;   // debug
- (void)startLocationMonitoring;
- (void)stopLocationMonitoringAndRanging;
- (NSArray *)availableNotifications;

- (void)startLocationMonitoringAndRanging; // debug

@property (readonly, retain) LPVisitor *visitor;

@end
