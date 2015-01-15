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

- (id)initWithFirebaseConfig:(NSDictionary *)firebaseConfig;
- (void)authenticateFirebase:(void (^)(void))successBlock;
@property (readonly, nonatomic) NSDictionary *firebaseConfig;
@property (readonly, nonatomic) NSDictionary *firebases;

@end
