//
//  KFUStreamViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 06.12.15.
//  Copyright © 2015 Alexander Drovnyashin. All rights reserved.
//

#import "KFUStreamViewController.h"

@interface KFUStreamViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *streamWebView;
@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;

@end

@implementation KFUStreamViewController

- (BOOL)KFUStream {
    
    return [self.navigationItem.title rangeOfString:@"KFU"].length > 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *urlString;
    if ([self KFUStream]) {
        
         urlString = @"http://cdn.universmotri.ru/live/univer_kfu2/playlist.m3u8";//@"http://cdn.universmotri.ru/live/
    }else
    
    urlString = @"http://universmotri.ru/lqcast/index.html";//@"http://cdn.universmotri.ru/live/smil:mbr.smil/playlist.m3u8";//@"http://radio.universmotri.ru:8000";
    //;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_streamWebView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"%d", [self KFUStream]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

@end
