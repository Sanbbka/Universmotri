//
//  DBMail.h
//  pfrf
//
//  Created by Alexander Drovnyashin on 04.12.15.
//  Copyright © 2015 АО "БАРС Груп". All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBMail : NSObject

@property (nonatomic, strong) dispatch_queue_t bgProcessBDWorkingQueue;
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;
@property (nonatomic, strong) NSManagedObjectContext *_daddyManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *_defaultManagedObjectContext;
@property (atomic, assign)    BOOL isReady;

+ (DBMail*)sharedInstance;
- (void)initWithCompletionBlock:(void(^)(BOOL success))block;

+ (NSManagedObjectContext*)mocMain;
+ (NSManagedObjectContext*)mocPerThread;

+ (void)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit complectionBlock:(void(^)(NSArray*))block;
+ (NSArray*)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit MOC:(NSManagedObjectContext*)context;
+ (NSInteger)countWithEntity:(NSString*)entity param:(NSDictionary*)param MOC:(NSManagedObjectContext*)context;

+ (BOOL)saveContext:(NSManagedObjectContext*)bgTaskContext;
+ (void)sayContextError:(NSError*)error;

+ (void)saveAllContext;

@end
