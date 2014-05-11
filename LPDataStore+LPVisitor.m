//
//  LPDataStore+LPVisitor.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPVisitor.h"

@implementation LPDataStore (LPVisitor)

- (void)registerVisitor:(NSUUID *)uuid
{
    [self identifyVisitor:uuid withExternalID:NULL];
}

- (void)identifyVisitor:(NSUUID *)uuid withExternalID:(NSString *)externalID
{
    Firebase *visitorsRef = [self.firebase childByAppendingPath:@"visitors"];
    Firebase *visitorRef = [visitorsRef childByAppendingPath:[uuid UUIDString]];
    [visitorRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value == [NSNull null]) {
            // New visitor
            NSDictionary *newVisitorInfo = @{@"created_at":[[NSDate date] description]};
            [visitorRef setValue:newVisitorInfo andPriority:kFirebaseServerValueTimestamp];
        }

        if ([externalID length]!=0) {
            NSDictionary *visitorInfo = @{@"external_id": externalID};
            [visitorRef updateChildValues:visitorInfo];
        }
    }];
}

@end
