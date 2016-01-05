//
//  NetworkHelper.h
//  Universmotri
//
//  Created by Alexander Drovnyashin on 05.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFUConstants.h"

@interface NetworkHelper : NSObject

+ (void)getNewsForType:(NewsID )uidNews complete:(void(^)(NSError *err))complete;

@end
