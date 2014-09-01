//
//  LPServerResponse.m
//  LoopPulse
//
//  Created by Thomas Pun on 9/1/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPServerResponse.h"

@implementation LPServerResponse

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        NSError *error;
        _defaults = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
        if (error!=nil){
            NSLog(@"Error converting server response to JSON: %@", error);
        }
        _isAuthenticated = [[_defaults objectForKey:@"authenticated"] boolValue];
    }
    return self;
}

@end
