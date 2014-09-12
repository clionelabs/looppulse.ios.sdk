//
//  LPDataStore+LPEngagementManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPEngagementManager.h"
#import "LoopPulse.h"

@implementation LPDataStore (LPEngagementManager)

- (Firebase *)engagementEventsRef
{
    return [self.firebases objectForKey:@"engagement_events"];
}

- (void)logEvent:(NSString *)eventType withEngagement:(LPEngagement *)engagement atTime:(NSDate *)createdAt
{
    NSUUID *visitorUUID = [[LoopPulse sharedInstance] visitorUUID];
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    NSDictionary *eventInfo = @{@"type": eventType,
                                @"visitor_uuid": [visitorUUID UUIDString],
                                @"created_at": [createdAt description]};
    NSMutableDictionary *engagementInfo = [[NSMutableDictionary alloc] initWithDictionary:engagement.payload];
    [engagementInfo addEntriesFromDictionary:eventInfo];

    Firebase *engagementRef = [[self engagementEventsRef] childByAutoId];
    [engagementRef setValue:engagementInfo andPriority:priority];
}
@end
