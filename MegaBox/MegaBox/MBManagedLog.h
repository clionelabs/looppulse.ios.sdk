//
//  MBManagedLog.h
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MBManagedLog : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * durationInSeconds;
@property (nonatomic, retain) NSDate * enteredAt;
@property (nonatomic, retain) NSNumber * exitedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * sortedBy;
@property (nonatomic, retain) NSString * body;
@end
