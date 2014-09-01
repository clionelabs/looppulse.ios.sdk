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

- (id)initWithToken:(NSString *)token andURLs:(NSDictionary *)urls
{
    self = [super init];
    if (self) {
        _token = token;
        _firebases = [self createFirebases:urls];
    }
    return self;
}

- (NSDictionary *)createFirebases:(NSDictionary *)urls
{
    NSMutableDictionary *firebases = [NSMutableDictionary dictionary];
    [urls enumerateKeysAndObjectsUsingBlock:^(id key, id url, BOOL *stop){
        Firebase *fb = [[Firebase alloc] initWithUrl:url];
        [firebases setObject:fb forKey:key];
    }];
    return firebases;
}

- (NSUUID *)visitorUUID
{
    NSString *uuidString = [LoopPulse.defaults objectForKey:@"visitorUUID"];
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}

@end
