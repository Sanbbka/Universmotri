//
//  BGProgress.h
//
//  Created by Alexandr Okhotnikov on 30.07.14.
//  Copyright (c) 2014 ЗАО "БАРС Груп". All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BGProgress : NSObject

@property (nonatomic,weak) UIView *parentView;
@property (nonatomic, assign) double progress;

+ (BGProgress*)showInView:(UIView*)view;
+ (BGProgress*)showMessage:(NSString*)message inView:(UIView*)view;
+ (void)showMessage:(NSString*)message inView:(UIView*)view hideDelay:(double)delay;
- (void)hideDelay:(double)delay message:(NSString*)message;

- (void)setProgress:(double)progress;

@end
