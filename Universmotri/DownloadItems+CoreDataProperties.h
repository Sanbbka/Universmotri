//
//  DownloadItems+CoreDataProperties.h
//  Universmotri
//
//  Created by Alexander Drovnyashin on 04.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DownloadItems.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadItems (CoreDataProperties)

@property (nonatomic) int64_t mainNewsPage;
@property (nonatomic) int64_t rectoratNewsPage;
@property (nonatomic) int64_t cultureNewsPage;
@property (nonatomic) int64_t scienceNewsPage;

@end

NS_ASSUME_NONNULL_END
