//
//  LPDataStore.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface LPDataStore : NSObject

- (id)initWithToken:(NSString *)token andURLs:(NSDictionary *)urls;

@property (readonly, nonatomic) NSDictionary *firebases;

@end
