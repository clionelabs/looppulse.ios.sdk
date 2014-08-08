//
//  LPDataStore+LPEngagementManager.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"

@interface LPDataStore (LPEngagementManager)
- (void)logEvent:(NSString *)eventType withEngagement:(NSDictionary *)engagement atTime:(NSDate *)createdAt;
@end
