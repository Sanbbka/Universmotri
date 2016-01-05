//
//  BGTouchView.m
//  pfrf
//
//  Created by Alexandr Okhotnikov on 23.03.15.
//  Copyright (c) 2015 АО "БАРС Груп". All rights reserved.
//

#import "BGTouchView.h"

@implementation BGTouchView
{
    BOOL view_pressed;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self view_animate_pressed:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self view_animate_pressed:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint position = [touch locationInView:self];
        if (position.x < -10 || position.x > self.bounds.size.width+10 || position.y < -10 || position.y > self.bounds.size.height+10) {
            [self view_animate_pressed:NO];
            break;
        }
    }
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    [self view_animate_pressed:NO];
}

- (void)view_animate_pressed:(BOOL)pressed
{
    if (pressed)
    {
        if (! view_pressed)
        {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.transform = CGAffineTransformMakeScale(1.015, 1.015);
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        view_pressed = YES;
    }
    else
    {
        if (view_pressed)
        {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        view_pressed = NO;
    }
}

@end
