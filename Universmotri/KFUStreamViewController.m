//
//  KFUStreamViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 06.12.15.
//  Copyright © 2015 Alexander Drovnyashin. All rights reserved.
//

#import "KFUStreamViewController.h"
#import <HTMLReader/HTMLReader.h>

@interface KFUStreamViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *streamWebView;
@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;

@property (strong , nonatomic) NSArray *arrProgram;

@property (assign, nonatomic) Stream stream;

@end

@implementation KFUStreamViewController

- (void)KFUStream {
    
    self.stream = [self.navigationItem.title rangeOfString:@"KFU"].length > 0 ? StreamKFU : StreamUniversmotri;
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
    
    self.arrProgram = [NSArray new];
    NSString *urlString;
    
    switch (self.stream) {
        case StreamKFU:
            urlString = @"http://cdn.universmotri.ru/live/univer_kfu2/playlist.m3u8";
            break;
        case StreamUniversmotri:
            urlString = @"http://universmotri.ru/lqcast/index.html";
            break;
        default:
            break;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_streamWebView loadRequest:urlRequest];
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
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStream] encoding:NSUTF8StringEncoding error:nil];
    HTMLDocument *document = [HTMLDocument documentWithString:str];
    NSString *schedule = [document textContent];
    NSArray *arrSchedule = [schedule componentsSeparatedByString:@"\n"];
    
    return arrSchedule;
}


#pragma mark - table delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row < self.arrProgram.count) {
        cell.textLabel.text = self.arrProgram[indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrProgram.count;
}

@end
