//
//  LPAuthManager.h
//  LoopPulse
//
//  Created by HiuKim on 2015-01-21.
//  Copyright (c) 2015 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPAuthManager : NSObject

@property (readonly, strong) NSString *applicationId;
@property (readonly, strong) NSString *token;
@property (readonly, strong) NSString *visitorUUID;

- (id)initWithApplicadtionId:(NSString *)applicationId andToken:(NSString *)token andVisitorUUID:(NSString *)visitorUUID;
- (void)authenticate:(void (^)(NSError *error))completionHandler;
- (BOOL)isAuthenticated;
- (BOOL)isAuthenticationExpired;

@end
