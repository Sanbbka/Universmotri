//
//  BGProgress.m
//
//  Created by Alexandr Okhotnikov on 30.07.14.
//  Copyright (c) 2014 ЗАО "БАРС Груп". All rights reserved.
//

#import "BGProgress.h"

@interface BGProgress ()
@property (nonatomic, strong) NSString *msgText;
@end

@implementation BGProgress
{
    NSInteger waitCount;
    UIView   *waitView;
    NSTimer  *waitViewTimer;
    NSTimer  *hideViewTimer;
    double    _progress;
}

@synthesize msgText, progress = _progress;

+ (BGProgress*)showInView:(UIView*)view
{
    BGProgress *prog_self = [[BGProgress alloc] init];
    
    prog_self.parentView = view;
    [prog_self showDelay:0.15];

    return prog_self;
}

+ (BGProgress*)showMessage:(NSString*)message inView:(UIView*)view
{
    BGProgress *prog_self = [[BGProgress alloc] init];
    
    if (message && [message isKindOfClass:[NSString class]])
        prog_self.msgText = message;
    else
        prog_self.msgText = @"Внимание";
    
    prog_self.parentView = view;
    [prog_self showDelay:0.15];
    
    return prog_self;
}

+ (void)showMessage:(NSString*)message inView:(UIView*)view hideDelay:(double)delay
{
    BGProgress *prog_self = [[BGProgress alloc] init];
    
    prog_self.parentView = view;
    [prog_self showDelay:0.0];

    [prog_self hideDelay:delay message:message];
}


- (id)init
{
    self = [super init];
    if (self) {
        waitCount     = 0;
        waitView      = nil;
        waitViewTimer = nil;
        hideViewTimer = nil;
        _progress     = -1;
    }
    return self;
}

- (void)showDelay:(double)delay
{
    if (self.parentView == nil)
        return;
    
    [self resetHideTimer];
    
    ++ waitCount;
    if (waitCount <= 1) {
        [self resetWaitTimer];
        waitViewTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(show) userInfo:nil repeats:NO];
    }
}

- (void)hideDelay:(double)delay message:(NSString*)message
{
    if (self.parentView == nil)
        return;

    if (message && [message isKindOfClass:[NSString class]])
        msgText = message;
    else
        msgText = @"Внимание";
    
    -- waitCount;
    if (waitCount <= 0) {
        [self resetWaitTimer];
        [self resetHideTimer];
        if (delay > 0.05) {
            [self show];
            hideViewTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
        }
        else
            [self dismiss];
    }
}

- (void)show
{
    UILabel *lblText = nil;
    UIProgressView *progressView = nil;

    if (waitView == nil)
    {
        waitView = [[UIView alloc] initWithFrame:self.parentView.bounds];
        waitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        waitView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        [self.parentView addSubview:waitView];
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center = CGPointMake(waitView.bounds.size.width/2, waitView.bounds.size.height/2);
        activity.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [waitView addSubview:activity];
        [activity startAnimating];
        
        lblText = [[UILabel alloc] initWithFrame:CGRectZero];
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.numberOfLines = 0;
        lblText.textColor = [UIColor whiteColor];
        lblText.font = [UIFont systemFontOfSize:18.0];
        lblText.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [waitView addSubview:lblText];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        progressView.tintColor = [UIColor colorWithRed:237/255.0 green:137/255.0 blue:104/255.0 alpha:1.0];
        [waitView addSubview:progressView];
    }
    else
    {
        for (UIView *vvv in waitView.subviews) {
            if ([vvv isKindOfClass:[UILabel class]]) {
                lblText = (UILabel*)vvv;
            }
            else if ([vvv isKindOfClass:[UIProgressView class]]) {
                progressView = (UIProgressView*)vvv;
            }
        }
    }

    lblText.text = msgText;

    CGFloat offsetProg = 12;
    CGSize labelSize = CGSizeZero;
    if (msgText != nil && msgText.length > 0)
    {
        CGSize textSize = [msgText boundingRectWithSize:CGSizeMake(waitView.bounds.size.width/3*2, waitView.bounds.size.height/2.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{ NSFontAttributeName : lblText.font }
                                                context:nil].size;
        labelSize.width  = ceil( textSize.width + 20 );
        labelSize.height = ceil( textSize.height + 20 );
    }
    
    if (self.progress >= 0.0) {
        if (labelSize.width <= 0) {
            labelSize.width  = 150.0;
            labelSize.height = offsetProg;
            offsetProg = 6;
        }
        else
            labelSize.height += 10.0;
        progressView.alpha = 1.0;
    }
    else {
        progressView.alpha = 0.0;
    }

    if (labelSize.width > 0)
    {
        lblText.frame = CGRectMake(ceil((waitView.bounds.size.width-labelSize.width)/2), ceil((waitView.bounds.size.height-labelSize.height)/2+50.0), labelSize.width, labelSize.height);
        lblText.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        lblText.layer.masksToBounds = YES;
        lblText.layer.cornerRadius = MIN( 8.0, ceil(labelSize.height/2) );
        
        CGRect rect = lblText.frame;
        rect.origin.x   += 5.0;
        rect.size.width -= 10;
        rect.origin.y    = rect.origin.y + rect.size.height - offsetProg;
        rect.size.height = 2;
        progressView.frame = rect;
        progressView.progress = self.progress;
    }
    else
        lblText.backgroundColor = [UIColor clearColor];
}

- (void)dismiss
{
    [self resetWaitTimer];
    [self resetHideTimer];
    if (waitView != nil) {
        [waitView removeFromSuperview];
        waitView = nil;
    }
    self.parentView = nil;
}

- (void)resetWaitTimer
{
    if (waitViewTimer != nil) {
        [waitViewTimer invalidate];
        waitViewTimer = nil;
    }
}

- (void)resetHideTimer
{
    if (hideViewTimer != nil) {
        [hideViewTimer invalidate];
        hideViewTimer = nil;
    }
}


#pragma mark - progress

- (void)setProgress:(double)progress
{
    _progress = progress;
    if (waitView) {
        [self show];
    }
}

- (double)progress
{
    return _progress;
}

@end
