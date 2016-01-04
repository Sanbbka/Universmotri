//
//  MainVC.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 06.12.15.
//  Copyright © 2015 Alexander Drovnyashin. All rights reserved.
//

#import "MainVC.h"
#import "KFUConstants.h"

@interface MainVC ()
{
    UIWebView *view;
}
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    


}


- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"firstSegue";
            break;
        case 1:
            identifier = @"secondSegue";
            break;
        case 2:
            identifier = @"News";
            break;
        case 3:
            identifier = @"Radio";
            break;
        case 4:
            identifier = @"settings";
            break;
            
        default:
            break;
    }
    
    return identifier;
}

- (void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0, 0};
    frame.size   = (CGSize){30, 25};
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"Menu-52"] forState:UIControlStateNormal];
}

- (CGFloat)leftMenuWidth
{
    return self.view.frame.size.width*85/100;
}

- (BOOL)deepnessForLeftMenu
{
    return YES;
}

@end
