//
//  LPAuthManager.m
//  LoopPulse
//
//  Created by HiuKim on 2015-01-21.
//  Copyright (c) 2015 Clione Labs. All rights reserved.
//

#import "LPAuthManager.h"
#import "LoopPulsePrivate.h"
#import "LPServerResponse.h"
#import "NSDictionary+LoopPulseHelpers.h"
#import "LPPoi.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"

@implementation LPAuthManager;

- (id)initWithApplicadtionId:(NSString *)applicationId andToken:(NSString *)token andVisitorUUID:(NSString *)visitorUUID
{
    self = [super init];
    if (self) {
        _applicationId = applicationId;
        _token = token;
        _visitorUUID = visitorUUID;
    }
    return self;
}

- (void)authenticate:(void (^)(NSError *error))completionHandler
{
    NSURLRequest *request = [self authenticationRequest];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *urlResonse, NSData *data, NSError *error) {
                               NSError *err;
                               LPServerResponse *response;

                               if (error != nil) {
                                   err = [NSError errorWithDomain:@"looppulse.com" code:400 userInfo:@{@"applicationId": _applicationId}];
                               } else {
                                   response = [[LPServerResponse alloc] initWithData:data];
                                   if (!response.isAuthenticated) {
                                      err = [NSError errorWithDomain:@"looppulse.com" code:401 userInfo:@{@"applicationId": _applicationId}];
                                   } else {
                                       [self saveServerResponse:response];
                                   }
                               }
                               completionHandler(err);
                           }];
}

- (void)refreshSavedResponse:(void (^)(NSError *error))completionHandler
{
    [self authenticate:^(NSError *error) {
        completionHandler(error);
    }];
}

- (NSURLRequest *)authenticationRequest
{
    NSString *url = [NSString stringWithFormat:@"%@%@", LPAuthenticationEndPoint, self.applicationId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:self.token forHTTPHeaderField:@"x-auth-token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *jsonString = [[self authenticationPayload] jsonString:@"capture"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    return request;
}

- (NSDictionary *)authenticationPayload
{
    // device
    // https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/index.html#//apple_ref/occ/instp/UIDevice/name
    UIDevice *uiDevice = [UIDevice currentDevice];
    NSDictionary *device = @{@"model": [uiDevice model],
                             @"systemVersion": [uiDevice systemVersion]};

    NSDictionary *sdk = @{@"version": [LoopPulse version]};
    NSDictionary *payload = @{@"visitorUUID": _visitorUUID,
                              @"sdk": sdk,
                              @"device": device};
    return payload;
}

- (BOOL)isAuthenticated
{
    return [LoopPulse.defaults objectForKey:@"lastResponseSavedTime"] != nil;
}

- (BOOL)updateAvailable
{
    if (![self isAuthenticated]) return NO;
    NSDate *last = [LoopPulse.defaults objectForKey:@"lastResponseSavedTime"];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:last];
    NSLog(@"auth interval: %f", interval);
    return interval > LPRefreshPeriodInSeconds;
}

// Set defaults with server response
- (void)saveServerResponse:(LPServerResponse *)response
{
    NSDictionary *system = response.systemConfiguration;

    NSDate *curr = [NSDate date];
    [LoopPulse.defaults setObject:curr forKey:@"lastResponseSavedTime"];

    [LoopPulse.defaults setObject:response.captureId forKey:@"captureId"];

    BOOL onlySendKnown = [[system objectForKey:@"onlySendBeaconEventsWithKnownProximity"] boolValue];
    [LoopPulse.defaults setBool:onlySendKnown forKey:@"onlySendBeaconEventsWithKnownProximity"];

    NSDictionary *firebaseDefaults = [system objectForKey:@"firebase"];
    [LoopPulse.defaults setObject:firebaseDefaults forKey:@"firebase"];

    NSDictionary *poisDefaults = [system objectForKey:@"pois"];
    [LoopPulse.defaults setObject:poisDefaults forKey:@"pois"];

    NSMutableDictionary *keyToName = [[NSMutableDictionary alloc] initWithCapacity:poisDefaults.count];
    for (NSDictionary *poiJSON in poisDefaults) {
        LPPoi *poi = [[LPPoi alloc] initWithDictionary:poiJSON];
        [keyToName setObject:poi.productName forKey:poi.key];
    }
    [LoopPulse.defaults setObject:keyToName forKey:@"beaconRegionKeyToProductName"];

    [LoopPulse.defaults synchronize];
}
@end
