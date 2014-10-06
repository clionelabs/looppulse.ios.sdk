//
//  LPServerResponse.m
//  LoopPulse
//
//  Created by Thomas Pun on 9/1/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPServerResponse.h"

@interface LPServerResponse ()
@property(nonatomic, retain) NSDictionary *defaults;
@end

@implementation LPServerResponse

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        NSError *error;
        self.defaults = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        if (error!=nil){
            NSLog(@"Error converting server response to JSON: %@", error);
        }
        _isAuthenticated = [[self.defaults objectForKey:@"authenticated"] boolValue];
        _systemConfiguration = [self.defaults objectForKey:@"system"];
    }
    return self;
}

@end
