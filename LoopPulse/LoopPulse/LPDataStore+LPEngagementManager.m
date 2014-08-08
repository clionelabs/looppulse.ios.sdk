//
//  LPDataStore+LPEngagementManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPEngagementManager.h"
#import "LPVisitor.h"

@implementation LPDataStore (LPEngagementManager)

- (Firebase *)engagementEventsRef
{
    return [self.firebase childByAppendingPath:@"engagement_events"];
}

- (void)logEvent:(NSString *)eventType withEngagement:(NSDictionary *)engagement atTime:(NSDate *)createdAt
{
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    NSDictionary *eventInfo = @{@"type": eventType,
                                @"visitor_uuid": [self.visitorUUID UUIDString],
                                @"created_at": [createdAt description]};
    NSMutableDictionary *engagementInfo = [[NSMutableDictionary alloc] initWithDictionary:engagement];
    [engagementInfo addEntriesFromDictionary:eventInfo];

    Firebase *engagementRef = [[self engagementEventsRef] childByAutoId];
    [engagementRef setValue:engagementInfo andPriority:priority];
}
@end
