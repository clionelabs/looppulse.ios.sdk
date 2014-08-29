//
//  LPEngagement.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPEngagement : NSObject

- (id)initWithPushPayload:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSDictionary *payload;
@property (nonatomic, readonly) NSURL *engagementURL;
@end
