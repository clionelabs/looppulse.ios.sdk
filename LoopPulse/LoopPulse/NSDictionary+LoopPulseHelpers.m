//
//  NSDictionary+LoopPulseHelpers.m
//  LoopPulse
//
//  Created by Thomas Pun on 10/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "NSDictionary+LoopPulseHelpers.h"

@implementation NSDictionary (LoopPulseHelpers)

- (NSString *)jsonString:(NSString *)rootKey
{
    NSDictionary *dict = self;
    if (rootKey) {
        dict = @{rootKey: self};
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0 // for compact JSON
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
