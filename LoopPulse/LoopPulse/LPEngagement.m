//
//  LPEngagement.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagement.h"

@interface LPEngagement ()
@property (nonatomic, retain) NSDictionary *payload;
@end

@implementation LPEngagement

- (id)initWithPushPayload:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _payload = dictionary;
    }
    return self;
}

@end
