//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"
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
        [fb authWithCustomToken:self.token
            withCompletionBlock: ^(NSError *error , FAuthData *authData) {
                if (error) {
                    NSLog(@"Error in Firebase authentication for %@: %@", url, error);
                } else {
                    [firebases setObject:fb forKey:key];
                    [self observeFirebaseAuthEvent:fb];
                }
            }];
    }];
    return firebases;
}

// https://www.firebase.com/docs/ios/guide/user-auth.html#section-monitoring-authentication
- (FirebaseHandle)observeFirebaseAuthEvent:(Firebase *)firebase
{
    return [firebase observeAuthEventWithBlock:^(FAuthData *authData) {
        if (!authData.auth) {
            // TODO: request new token or stop all tracking
            NSLog(@"Access revoked: %@", firebase);
        }
    }];
}

@end
