//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"
#import "LPVisitor.h"
#import "LoopPulsePrivate.h"

@interface LPDataStore ()
@property (readonly, retain) NSString *token;
@end

@implementation LPDataStore

- (id)initWithToken:(NSString *)token andBaseUrl:(NSString *)baseUrl
{
    self = [super init];
    if (self) {
        _token = token;
        _firebase = [[Firebase alloc] initWithUrl:baseUrl];
    }
    return self;
}

- (NSUUID *)visitorUUID
{
    NSString *uuidString = [LoopPulse.defaults objectForKey:@"visitorUUID"];
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}

@end
