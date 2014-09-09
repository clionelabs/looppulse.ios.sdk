//
//  LPInstallation.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/16/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LPInstallation : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isEqual:(LPInstallation *)other;
- (BOOL)isNearby:(LPInstallation *)otherInstallation;

@property(readonly) CLBeaconRegion *beaconRegion;
@property(readonly) NSString *key;
@property(readonly) NSString *productName;

@end
