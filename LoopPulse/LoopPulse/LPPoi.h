//
//  LPPoi.h
//  LoopPulse
//
//  Created by HiuKim on 2015-01-08.
//  Copyright (c) 2015 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LPPoi : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property(readonly) CLBeaconRegion *beaconRegion;
@property(readonly) NSString *key;
@property(readonly) NSString *productName;

@end
