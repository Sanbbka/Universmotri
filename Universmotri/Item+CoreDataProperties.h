//
//  Item+CoreDataProperties.h
//  Universmotri
//
//  Created by Alexander Drovnyashin on 07.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *detailFullText;
@property (nullable, nonatomic, retain) NSString *detailItemLink;
@property (nullable, nonatomic, retain) NSString *detailYoutubeLink;
@property (nullable, nonatomic, retain) NSData *itemImage;
@property (nullable, nonatomic, retain) NSString *itemLinkImage;
@property (nullable, nonatomic, retain) NSString *itemTime;
@property (nullable, nonatomic, retain) NSString *itemTittle;
@property (nonatomic) int16_t newsUid;
@property (nonatomic) int16_t uidNews;
@property (nonatomic) int64_t priority;

@end

NS_ASSUME_NONNULL_END
