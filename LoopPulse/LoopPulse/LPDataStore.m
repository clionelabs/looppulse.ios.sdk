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

- (id)initWithURLs:(NSDictionary *)urls
{
    self = [super init];
    if (self) {
        _urls = urls;
    }
    return self;
}

- (void)authenticateFirebase:(NSString *) token withSuccessBlock:(void (^)(void))successBlock
{
    _token = token;
    NSString *root = [self.urls objectForKey:@"root"];
    Firebase *firebase = [[Firebase alloc] initWithUrl:root];
    [firebase authWithCustomToken:token
              withCompletionBlock:^(NSError *error, FAuthData *authData){
                  if (error) {
                      NSLog(@"Error in Firebase authentication for %@: %@", root, error);
                  } else {
                      _firebases = [self createFirebases:self.urls];
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
