//
//  DBMail.m
//  pfrf
//
//  Created by Alexander Drovnyashin on 04.12.15.
//  Copyright © 2015 АО "БАРС Груп". All rights reserved.
//

#import "DBMail.h"
#import "BGTools.h"

@implementation DBMail

+ (DBMail*)sharedInstance
{
    static id _singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[DBMail alloc] init];
    });
    return _singleton;
}

+ (dispatch_queue_t)processBDWorkingQueue
{
    return [DBMail sharedInstance].bgProcessBDWorkingQueue;
}

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        self.isReady = NO;
        self.bgProcessBDWorkingQueue = dispatch_queue_create("MailDB.processBDWorkingQueue", NULL);
    }
    
    return self;
}

- (void)initWithCompletionBlock:(void(^)(BOOL success))block
{
    if (self.isReady) {
        block( YES );
        return;
    }
    
    dispatch_async( self.bgProcessBDWorkingQueue, ^{
        
        // Создание NSManagedObjectModel
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ItemModel" withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // Создаем NSPersistentStoreCoordinator
        self.psc =  [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        // Добавляем к NSPersistentStoreCoordinator хранилище, именно на этой операции приложение может висеть очень долго
        
        NSPersistentStore *store = nil;
        NSInteger retryCount = 0;
        do {
            
            NSURL *storeDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            storeDirURL = [storeDirURL URLByAppendingPathComponent:@"storeKFUV1" isDirectory:YES];
            [[NSFileManager defaultManager] createDirectoryAtURL:storeDirURL withIntermediateDirectories:NO attributes:nil error:nil];
            [BGTools addSkipBackupAttributeToItemAtURL:storeDirURL];
            
            NSURL *storeURL = [storeDirURL URLByAppendingPathComponent:@"ItemModel.sqlite"];
#ifdef DEBUG
            NSLog(@"SqlLiteKFU: %@", storeURL.path);
#endif
            
            NSError *error = nil;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            store = [self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
            
            if (!store)
            {
                if (retryCount > 1) {
                    NSLog(@"addPersistentStore (%@): Unresolved error %@, %@", storeURL.path, error, [error userInfo]);
                    block( NO );
                    abort();
                }
                ++ retryCount;
                [[NSFileManager defaultManager] removeItemAtURL:storeDirURL error:&error];
            }
            
        } while (!store);
        
        // Создание контекстов
        
        // _daddyManagedObjectContext является настоящим отцом всех дочерних контекстов юзер кода, он приватен.
        
        self._daddyManagedObjectContext = [[NSManagedObjectContext alloc]  initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [self._daddyManagedObjectContext setPersistentStoreCoordinator:self.psc];
        [self._daddyManagedObjectContext setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
        // Далее в главном потоке инициализируем main-thread context, он будет доступен пользователям
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self._defaultManagedObjectContext = [[NSManagedObjectContext alloc]  initWithConcurrencyType:NSMainQueueConcurrencyType];
            // Добавляем наш приватный контекст отцом, чтобы дочка смогла пушить все изменения
            [self._defaultManagedObjectContext setParentContext:self._daddyManagedObjectContext];
            [self._defaultManagedObjectContext setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
            
            self.isReady = YES;
            block( YES );
            
        });
    });
}

+ (NSManagedObjectContext*)mocMain
{
    return [DBMail sharedInstance]._defaultManagedObjectContext;
}

+ (NSManagedObjectContext*)mocPerThread
{
    DBMail *_self = [DBMail sharedInstance];
    
    while (! _self.isReady) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    NSManagedObjectContext *context;
    
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:_self._defaultManagedObjectContext];
    [context setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
    
    return context;
}

+ (BOOL)saveContext:(NSManagedObjectContext*)bgTaskContext
{
    BOOL __block retVal = YES;
    
    if (bgTaskContext.hasChanges) {
        [bgTaskContext performBlockAndWait:^{
            NSError *error = nil;
            if (! [bgTaskContext save:&error]) {
                [self sayContextError:error];
                retVal = NO;
            }
        }];
        
        DBMail *_self = [DBMail sharedInstance];
        
        // Save default context
        if (_self._defaultManagedObjectContext.hasChanges) {
            [_self._defaultManagedObjectContext performBlockAndWait:^{
                NSError *error = nil;
                if (! [_self._defaultManagedObjectContext save:&error])
                    [self sayContextError:error];
            }];
            
            // А после сохранения _defaultManagedObjectContext необходимо сохранить его родителя, то есть _daddyManagedObjectContext
            [_self._daddyManagedObjectContext performBlockAndWait:^{
                NSError *error = nil;
                if (! [_self._daddyManagedObjectContext save:&error])
                    [self sayContextError:error];
            }];
        }
    }
    
    return retVal;
}

+ (void)saveAllContext
{
    DBMail *_self = [DBMail sharedInstance];
    
    NSError *error = nil;
    if ([_self._defaultManagedObjectContext hasChanges] && ![_self._defaultManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        [self sayContextError:error];
        //            abort();
    }
}

+ (void)sayContextError:(NSError*)error
{
    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
        for(NSError* detailedError in detailedErrors) {
            NSLog(@"    sayContextError DetailedError: %@", [detailedError userInfo]);
        }
    }
    else {
        NSLog(@"    sayContextError %@", [error userInfo]);
    }
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (id)objectsWithIDs:(id)collection MOC:(NSManagedObjectContext*)context
{
    if (![collection isKindOfClass:[NSArray class]] && ![collection isKindOfClass:[NSSet class]])
        return nil;
    
    if (context == nil)
        context = [DBMail mocPerThread];
    
    id newCollection = [[[[collection class] alloc] init] mutableCopy];
    for (NSManagedObjectID *objectID in collection) {
        @try {
            NSManagedObject *obj = [context objectWithID:objectID];
            [newCollection addObject:obj];
        }
        @catch (NSException *exception) {
            NSLog(@"\n\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Failed objectsWithIDs: %@\n\n\n", exception.reason);
        }
    }
    
    return [newCollection copy];
}

+ (id)objectWithID:(id)objectID MOC:(NSManagedObjectContext*)context
{
    if (context == nil)
        context = [DBMail mocPerThread];
    
    @try {
        NSManagedObject *obj = [context objectWithID:objectID];
        return obj;
    }
    @catch (NSException *exception) {
        NSLog(@"\n\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Failed objectWithID: %@\n\n\n", exception.reason);
    }
    
    return nil;
}


#pragma mark -

+ (NSArray*)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit MOC:(NSManagedObjectContext*)context
{
    if (context == nil)
        context = [DBMail mocPerThread];
    
    __block NSArray *retVal = nil;
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
        
        if (offset > 0)
            [fetchRequest setFetchOffset:offset];
        if (limit > 0)
            [fetchRequest setFetchLimit:limit];
        
        [self predicateForRequest:fetchRequest filters:param];
        
        if (sort && sort.count > 0)
        {
            NSMutableArray *sortDesc = [NSMutableArray arrayWithCapacity:sort.count];
            for (NSString *key in sort) {
                [sortDesc addObject: [NSSortDescriptor sortDescriptorWithKey:key ascending:[sort[key] boolValue]] ];
            }
            [fetchRequest setSortDescriptors:sortDesc];
        }
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        if (results == nil || error) {
            [self sayContextError:error];
        }
        else if (results.count > 0)
        {
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:results.count];
            for (NSManagedObject *obj in results) {
                if (obj.managedObjectContext != nil && obj.objectID && [context existingObjectWithID:obj.objectID error:NULL] != nil)
                    [arr addObject:obj];
            }
            if (arr.count > 0)
                retVal = arr;
        }
    }];
    
    return retVal;
}

+ (NSInteger)countWithEntity:(NSString*)entity param:(NSDictionary*)param MOC:(NSManagedObjectContext*)context
{
    if (context == nil)
        context = [DBMail mocPerThread];
    
    __block NSInteger retVal = -1;
    [context performBlockAndWait:^{
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
        
        [self predicateForRequest:fetchRequest filters:param];
        
        NSError *error = nil;
        NSUInteger results = [context countForFetchRequest:fetchRequest error:&error];
        if(results == NSNotFound || error) {
            [self sayContextError:error];
        }
        else
        {
            retVal = results;
        }
    }];
    
    return retVal;
}

+ (NSArray*)objectIDsWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit MOC:(NSManagedObjectContext*)context
{
    NSArray *objects = [self objectWithEntity:entity param:param sort:sort offset:offset limit:limit MOC:context];
    if (! objects)
        return objects;
    
    return [objects valueForKey:@"objectID"];
}

+ (void)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit complectionBlock:(void(^)(NSArray*))block
{
    NSManagedObjectContext *context = [DBMail mocPerThread];
    [context performBlock:^{
        
        NSArray *objectIDs = [self objectIDsWithEntity:entity param:param sort:sort offset:offset limit:limit MOC:context];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block( [self objectsWithIDs:objectIDs MOC:[self mocMain]] );
        });
    }];
}

+ (void)predicateForRequest:(NSFetchRequest*)fetchRequest filters:(NSDictionary*)filters
{
    if (filters && filters.count > 0)
    {
        NSMutableArray *preds = [NSMutableArray arrayWithCapacity:filters.count];
        for (NSString *key in filters) {
            if ([filters[key] isKindOfClass:[NSArray class]]) {
                if ([key hasSuffix:@"!"]) {
                    NSString *key2 = [key substringToIndex:key.length-1];
                    if ([key2 caseInsensitiveCompare:@"self"] == NSOrderedSame)
                        [preds addObject:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", filters[key]]];
                    else
                        [preds addObject:[NSPredicate predicateWithFormat:@"NOT (%K IN %@)", key2, filters[key]]];
                }
                else {
                    if ([key caseInsensitiveCompare:@"self"] == NSOrderedSame)
                        [preds addObject:[NSPredicate predicateWithFormat:@"(SELF IN %@)", filters[key]]];
                    else
                        [preds addObject:[NSPredicate predicateWithFormat:@"(%K IN %@)", key, filters[key]]];
                }
            }
            else {
                if ([key hasSuffix:@">"]) {
                    NSString *key2 = [key substringToIndex:key.length-1];
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K > %@", key2, filters[key]]];
                }
                else if ([key hasSuffix:@"<"]) {
                    NSString *key2 = [key substringToIndex:key.length-1];
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K < %@", key2, filters[key]]];
                }
                else if ([key hasSuffix:@"!"]) {
                    NSString *key2 = [key substringToIndex:key.length-1];
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K != %@", key2, filters[key]]];
                }
                else if ([key hasSuffix:@">="]) {
                    NSString *key2 = [key substringToIndex:key.length-2];
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K >= %@", key2, filters[key]]];
                }
                else if ([key hasSuffix:@"<="]) {
                    NSString *key2 = [key substringToIndex:key.length-2];
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K <= %@", key2, filters[key]]];
                }
                else
                    [preds addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, filters[key]]];
            }
        }
        NSPredicate  *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
        [fetchRequest setPredicate:predicate];
    }
}

@end
