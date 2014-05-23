//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"

@implementation LPDataStore

- (id)initWithToken:(NSString *)token clientID:(NSString *)clientID
{
    self = [super init];
    if (self) {
        
        if (token.length == 0) {
            [NSException raise:@"Invalid token value" format:@"The token parameter must be provided."];
        }
        if (clientID.length == 0) {
            [NSException raise:@"Invalid clientID value" format:@"The clientID parameter must be provided."];
        }
        
        _token = token;
        _clientID = clientID;
        NSString *url = [NSString stringWithFormat:@"https://looppulse-dev.firebaseio.com/clients/%@", clientID];
        _firebase = [[Firebase alloc] initWithUrl:url];
    }
    return self;
}

@end
