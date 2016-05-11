//
//  KFUStreamViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 06.12.15.
//  Copyright © 2015 Alexander Drovnyashin. All rights reserved.
//

#import "KFUStreamViewController.h"
#import <HTMLReader/HTMLReader.h>

@import AVKit;
@import AVFoundation;

@interface KFUStreamViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView      *streamWebView;
@property (weak, nonatomic) IBOutlet UITableView    *scheduleTableView;

@property (strong , nonatomic) NSArray *arrProgram;
@property (weak, nonatomic) IBOutlet UIView *player;
@property (strong , nonatomic) AVPlayerViewController *playerVC;
@property (assign, nonatomic) Stream stream;

@end

@implementation KFUStreamViewController

- (void)KFUStream {
    
    self.stream = [self.navigationItem.title rangeOfString:@"KFU"].length > 0 ? StreamKFU : StreamUniversmotri;
    
    // ...
   
}

-(void)updateInfo {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.arrProgram = [self getSchedule];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.scheduleTableView reloadData];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self KFUStream];
    
    [self.scheduleTableView setTableFooterView:[UIView new]];
    
    self.arrProgram = [NSArray new];
    NSString *urlString;
    
    switch (self.stream) {
        case StreamKFU:
            urlString = @"http://cdn.universmotri.ru/live/univer_kfu2/playlist.m3u8";
            break;
        case StreamUniversmotri:
            urlString = @"http://cdn.universmotri.ru/live/smil:mbr.smil/playlist.m3u8";
            break;
        default:
            break;
    }
    
    self.playerVC = [[AVPlayerViewController alloc] init];
    [self.playerVC.view setFrame: self.player.bounds];  // player's frame must match parent's
    [self.player addSubview: self.playerVC.view];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.streamWebView loadRequest:urlRequest];
    self.streamWebView.scrollView.scrollEnabled = YES;
    self.streamWebView.delegate = self;
    
    self.playerVC.player = [AVPlayer playerWithURL:url];
    [self.playerVC.player play];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self updateInfo];
}


#pragma mark - online
- (NSArray *)getSchedule {
    
    NSString *urlStream;
    
    switch (self.stream) {
        case StreamKFU:
            urlStream = @"http://tv.kpfu.ru/epg_kpfu";
            break;
        case StreamUniversmotri:
            urlStream = @"http://tv.kpfu.ru/epg_universmotri";
            break;
        default:
            urlStream = @"http://tv.kpfu.ru/epg_kpfu";
            break;
    }
    
    NSError *err;
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStream] encoding:NSUTF8StringEncoding error:&err];
    NSArray *arrSchedule;
    if (str) {
        
        HTMLDocument *document = [HTMLDocument documentWithString:str];
        NSString *schedule = [document textContent];
        arrSchedule = [schedule componentsSeparatedByString:@"\n"];
        
    }
    if (err) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка!!!"
                                                                       message:@"Ошибка сети, повторите запрос позднее."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return arrSchedule;
}


#pragma mark - table delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    [cell setBackgroundColor:[UIColor colorWithRed:54./255. green:57./255. blue:81./255. alpha:1.]];
    
    if (indexPath.row < self.arrProgram.count) {
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        cell.textLabel.text = self.arrProgram[indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrProgram.count;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"start");
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
 
    NSLog(@"start");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"stop");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"stop");
}

@end
