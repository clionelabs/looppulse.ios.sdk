//
//  LPDataStore+LPVisitor.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPVisitor.h"

@implementation LPDataStore (LPVisitor)

- (Firebase *)visitorEventsRef
{
    return [self.firebases objectForKey:@"visitor_events"];
}

- (void)identifyVisitor:(NSUUID *)uuid withExternalID:(NSString *)externalID
{
    [self pushVisitorEvent:@{@"type": @"identify",
                             @"visitor_uuid": [uuid UUIDString],
                             @"external_id": externalID}];
}

- (void)tagVisitor:(NSUUID *)uuid withProperties:(NSDictionary *)properties
{
    [self pushVisitorEvent:@{@"type": @"tag",
                             @"visitor_uuid": [uuid UUIDString],
                             @"properties": properties}];
}

- (void)trackVisitor:(NSUUID *)uuid withEventName:(NSString *)eventName andProperties:(NSDictionary *)properties
{
    [self pushVisitorEvent:@{@"type": @"track",
                             @"event_name": eventName,
                             @"visitor_uuid": [uuid UUIDString],
                             @"properties": properties}];
}

// Automatically add created_at and priority before pushing to Firebase
- (void)pushVisitorEvent:(NSDictionary *)event
{
    NSDate *createdAt = [NSDate date];
    NSMutableDictionary *finalEvent = [NSMutableDictionary dictionaryWithDictionary:@{@"created_at": [createdAt description]}];
    [finalEvent addEntriesFromDictionary:event];

    Firebase *visitor_event_ref = [[self visitorEventsRef] childByAutoId];
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    [visitor_event_ref setValue:finalEvent andPriority:priority];
}

@end
