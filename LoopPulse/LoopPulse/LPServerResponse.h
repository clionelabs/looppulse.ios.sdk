//
//  LPServerResponse.h
//  LoopPulse
//
//  Created by Thomas Pun on 9/1/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPServerResponse : NSObject

- (id)initWithData:(NSData *)data;

@property(nonatomic, readonly) BOOL isAuthenticated;
@property(nonatomic, readonly) NSDictionary *systemConfiguration;
@property(nonatomic, readonly) NSString *session;

@end
