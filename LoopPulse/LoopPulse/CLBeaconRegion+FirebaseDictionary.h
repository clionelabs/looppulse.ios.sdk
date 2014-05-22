//
//  CLBeaconRegion+FirebaseDictionary.h
//  LightHouse
//
//  Created by Thomas Pun on 5/3/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLBeaconRegion (FirebaseDictionary)
- (NSDictionary *)firebaseDictionary;
@end
