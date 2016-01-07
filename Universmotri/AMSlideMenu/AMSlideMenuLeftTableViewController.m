//
//  AMSlideMenuLeftTableViewController.m
//  AMSlideMenu
//
// The MIT License (MIT)
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "AMSlideMenuLeftTableViewController.h"

#import "AMSlideMenuMainViewController.h"

#import "AMSlideMenuContentSegue.h"

@import AVFoundation;

@interface AMSlideMenuLeftTableViewController ()
{
    AVPlayer *songPlayer;

    __weak IBOutlet UITableViewCell *customCellSetting;
    __weak IBOutlet UITableViewCell *customCellNews;
    __weak IBOutlet UITableViewCell *customCellKFU;
    __weak IBOutlet UITableViewCell *customCellUniversmotri;
}
@end

@implementation AMSlideMenuLeftTableViewController

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/
- (IBAction)radioContr:(UISwitch *)sender {

    NSLog(@"%lu", (unsigned long)sender.isOn);
    if (sender.isOn) {
        
        [self playselectedsong];
    } else {
        [songPlayer pause];
    }
}
-(void)playselectedsong{
    if (songPlayer) {
        [songPlayer play];
    } else {
    NSString *urlString = @"http://radio.universmotri.ru:8000";
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:urlString]];
    songPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[songPlayer currentItem]];
    [songPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    
    }
    
}
-(void)updateProgress{
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == songPlayer && [keyPath isEqualToString:@"status"]) {
        if (songPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (songPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [songPlayer play];
            
            
        } else if (songPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    NSLog(@"dsada!!!!!!!!!!!!!!");
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *bgrnd = [[UIView alloc] initWithFrame:customCellKFU.bounds];
    [bgrnd                  setBackgroundColor:[UIColor blackColor]];
    [customCellKFU          setSelectedBackgroundView:bgrnd];
    [customCellNews         setSelectedBackgroundView:bgrnd];
    [customCellSetting      setSelectedBackgroundView:bgrnd];
    [customCellUniversmotri setSelectedBackgroundView:bgrnd];
}

- (void)openContentNavigationController:(UINavigationController *)nvc
{
#ifdef AMSlideMenuWithoutStoryboards
    AMSlideMenuContentSegue *contentSegue = [[AMSlideMenuContentSegue alloc] initWithIdentifier:@"contentSegue" source:self destination:nvc];
    [contentSegue perform];
#else
    NSLog(@"This methos is only for NON storyboard use! You must define AMSlideMenuWithoutStoryboards \n (e.g. #define AMSlideMenuWithoutStoryboards)");
#endif
}


/*----------------------------------------------------*/
#pragma mark - TableView Delegate -
/*----------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *bgrnd = [[UIView alloc] initWithFrame:[tableView cellForRowAtIndexPath:indexPath].bounds];
    [bgrnd setBackgroundColor:[UIColor blackColor]];
    [[tableView cellForRowAtIndexPath:indexPath] setSelectedBackgroundView:bgrnd];
    
    if ([self.mainVC respondsToSelector:@selector(navigationControllerForIndexPathInLeftMenu:)]) {
        UINavigationController *navController = [self.mainVC navigationControllerForIndexPathInLeftMenu:indexPath];
        AMSlideMenuContentSegue *segue = [[AMSlideMenuContentSegue alloc] initWithIdentifier:@"ContentSugue" source:self destination:navController];
        [segue perform];
    } else {
        NSString *segueIdentifier = [self.mainVC segueIdentifierForIndexPathInLeftMenu:indexPath];
        if (segueIdentifier && segueIdentifier.length > 0)
        {
            [self performSegueWithIdentifier:segueIdentifier sender:self];
        }
    }
}




@end
