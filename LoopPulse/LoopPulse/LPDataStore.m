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
@property (readonly, retain) NSDictionary *urls;
@end

@implementation LPDataStore

- (id)initWithFirebaseConfig:(NSDictionary *)firebaseConfig
{
    self = [super init];
    if (self) {
        _firebaseConfig = firebaseConfig;
    }
    return self;
}

- (void)authenticateFirebase:(void (^)(void))successBlock {
    NSString *root = [_firebaseConfig objectForKey:@"root"];
    NSString *token = [_firebaseConfig objectForKey:@"token"];
    NSDictionary *paths = [_firebaseConfig objectForKey:@"paths"];

    Firebase *firebase = [[Firebase alloc] initWithUrl:root];
    [firebase authWithCustomToken:token
              withCompletionBlock:^(NSError *error, FAuthData *authData){
                  if (error) {
                      NSLog(@"Error in Firebase authentication for %@: %@", root, error);
                  } else {
                      _firebases = [self createFirebases:paths];
                      [self observeFirebaseAuthEvent:firebase];
                      successBlock();
                  }
              }
     ];
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
