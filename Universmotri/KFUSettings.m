//
//  KFUSettings.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 03.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "KFUSettings.h"
@interface KFUSettings()



@end

@implementation KFUSettings

+ (instancetype)sharedManager {
    static KFUSettings *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

@end
