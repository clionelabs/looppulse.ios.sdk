//
//  MBLogController.m
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "MBLogController.h"
#import <Firebase/Firebase.h>
#import <LoopPulse/LoopPulse.h>
#import <CoreLocation/CoreLocation.h>

#define kFirechatLogNS @"https://looppulse-beta.firebaseio.com/visitors/%@/logs"
#define kFirechatLogToken @"ha5jJXD3ac6DzOWoNfxPunOvrfvK68gQXwodfnn9"
//#define kFirechatLogNS @"https://hiukim-lp-dev-beacon.firebaseio.com/visitors/%@/logs"
//#define kFirechatLogToken @"a8heWtUdnNAGliQwJ25cX7UWGy5cYwWf4EYegtQB"

#define kCoreDataEntity @"MBManagedLog"
#define kCoreDataKeyAttribute @"name"

@interface MBLogController ()
@property (strong, nonatomic) Firebase* firebase;
@property (assign, nonatomic) FirebaseHandle firebaseAddObserver;
@property (assign, nonatomic) FirebaseHandle firebaseChangeObserver;
@property (assign, nonatomic) FirebaseHandle firebaseRemoveObserver;
@property (assign, nonatomic) FirebaseHandle firebaseValueObserver;
@end

@implementation MBLogController

- (NSString *)firechatNamespace
{
    return [NSString stringWithFormat:kFirechatLogNS, self.loopPulse.visitorUUID.UUIDString];
}

- (void)startLogMonitoring
{
    NSLog(@"Loading log data");

    self.firebase = [[Firebase alloc] initWithUrl:[self firechatNamespace]];
    [self.firebase authWithCustomToken:kFirechatLogToken
              withCompletionBlock:^(NSError *error, FAuthData *authData){
                  if (error) {
                      NSLog(@"Error in Firebase authentication for %@: %@", [self firechatNamespace], error);
                  } else {
                      [self deleteCoreDataManagedObjectsThatNoLongerExistInFirebase:self.firebase];
                      [self observeFirebase];
                  }
              }
     ];
}

- (void)stopLogMonitoring
{
    [self.firebase removeObserverWithHandle:self.firebaseAddObserver];
    [self.firebase removeObserverWithHandle:self.firebaseChangeObserver];
    [self.firebase removeObserverWithHandle:self.firebaseRemoveObserver];
    [self.firebase removeObserverWithHandle:self.firebaseValueObserver];
}

- (void)observeFirebase
{
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self updateCoreDataEntity:kCoreDataEntity snapshot:snapshot];
    }];
    
    [self.firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self updateCoreDataEntity:kCoreDataEntity snapshot:snapshot];
    }];
    
    [self.firebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [self removeCoreDataEntity:kCoreDataEntity snapshot:snapshot];
    }];
    
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self saveContext];
    }];
}

- (NSManagedObject *)fetchCoreDataManagedObjectWithEntityName:(NSString *)entityName firebaseKey:(NSString *)firebaseKey
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kCoreDataKeyAttribute, firebaseKey]];
    [fetchRequest setFetchLimit:1];
    return [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

- (void)removeCoreDataEntity:(NSString *)entityName snapshot:(FDataSnapshot *)snapshot
{
    NSManagedObject *managedObject = [self fetchCoreDataManagedObjectWithEntityName:kCoreDataEntity firebaseKey:snapshot.key];
    if (managedObject) {
        [self.managedObjectContext deleteObject:managedObject];
    }
}

- (void)addEventWithType:(NSString *)eventType andMsg:(NSString *)msg
{
//    NSString *eventType = [userInfo objectForKey:@"eventType"];
//    CLBeaconRegion *region = [userInfo objectForKey:@"beaconRegion"];

    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataEntity inManagedObjectContext:self.managedObjectContext];
    [managedObject setValue:eventType forKey:@"type"];
    [managedObject setValue:msg forKey:@"body"];
    [managedObject setValue:[NSDate date] forKey:@"createdAt"];
    [self saveContext];
}

- (void)updateCoreDataEntity:(NSString *)entityName snapshot:(FDataSnapshot *)snapshot
{
    NSString *firebaseKey = snapshot.key;
    NSDictionary *properties = snapshot.value;

    if ((id)properties == [NSNull null]) return;
    
    NSManagedObject *managedObject = [self fetchCoreDataManagedObjectWithEntityName:entityName firebaseKey:firebaseKey];
    if (!managedObject) {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [managedObject setValue:firebaseKey forKey:kCoreDataKeyAttribute];
    }
    
    [managedObject setValue:snapshot.key forKey:@"name"];
    if (properties[@"sortedBy"] != [NSNull null]) {
        [managedObject setValue:properties[@"sortedBy"] forKey:@"sortedBy"];
    }
    if (properties[@"durationInSeconds"] != [NSNull null]) {
        [managedObject setValue:properties[@"durationInSeconds"] forKey:@"durationInSeconds"];
    }
    if (properties[@"enteredAt"] != [NSNull null]) {
        NSDate *enteredAt = [NSDate dateWithTimeIntervalSince1970:[properties[@"enteredAt"] doubleValue] / 1000.0];
        [managedObject setValue:enteredAt forKey:@"enteredAt"];
    }
    if (properties[@"exitedAt"] != [NSNull null]) {
        NSDate *exitedAt = [NSDate dateWithTimeIntervalSince1970:[properties[@"exitedAt"] doubleValue] / 1000.0];
        [managedObject setValue:exitedAt forKey:@"exitedAt"];
    }
    if (properties[@"createdAt"] != [NSNull null]) {
        NSDate *createdAt = [NSDate dateWithTimeIntervalSince1970:[properties[@"createdAt"] doubleValue] / 1000.0];
        [managedObject setValue:createdAt forKey:@"createdAt"];
    }
    if (properties[@"location"] != [NSNull null]) {
        [managedObject setValue:properties[@"location"] forKey:@"location"];
    }
    if (properties[@"body"] != [NSNull null]) {
        [managedObject setValue:properties[@"body"] forKey:@"body"];
    }
    if (properties[@"type"] != [NSNull null]) {
        [managedObject setValue:properties[@"type"] forKey:@"type"];
    }
}

- (void)deleteCoreDataManagedObjectsThatNoLongerExistInFirebase:(Firebase *)firebase
{
    void (^identifierBlock)(FDataSnapshot *snapshot) = ^(FDataSnapshot *snapshot) {
        NSMutableArray *uniqueIdentifiers = [[NSMutableArray alloc] init];
        for (FDataSnapshot *child in snapshot.children) {
            [uniqueIdentifiers addObject:child.key];
        };
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kCoreDataEntity];
        [fetchRequest setIncludesPropertyValues:NO];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (%K IN %@)", kCoreDataKeyAttribute, uniqueIdentifiers]];
        
        NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        for (NSManagedObject *managedObject in objects) {
            [self.managedObjectContext deleteObject:managedObject];
        }
        
    };
    [firebase observeSingleEventOfType:FEventTypeValue withBlock:identifierBlock];
}

- (void)saveContext
{
    NSError *error = nil;
    NSLog(@"Saving managed object context");
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
