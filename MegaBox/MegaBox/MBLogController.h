//
//  MBLogController.h
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoopPulse;

@interface MBLogController : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) LoopPulse *loopPulse;

- (void)startLogMonitoring;
- (void)stopLogMonitoring;

@end
