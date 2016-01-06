//
//  DetailViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 06.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "DetailViewController.h"
#import "DBMail.h"
#import "NetworkHelper.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UITextView *detailFullTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;

@property (nonatomic, strong)NSManagedObjectContext *moc;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _moc = [DBMail mocPerThread];
    
    [_moc performBlock:^{
        
        NSArray *arr = [DBMail objectWithEntity:@"Item" param:@{@"newsUid" : [NSNumber numberWithInt:(int)self.newsID]} sort:nil offset:0 limit:0 MOC:_moc];
        Item *item = arr.firstObject;
        
        if (item.detailFullText && item.detailYoutubeLink) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [self.detailFullTextView setText:item.detailFullText];
            [self.detailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:item.detailYoutubeLink]]];
            [self.refreshIndicator stopAnimating];
                });
        } else {
            [NetworkHelper getDetailNewsByDetailHref:item.detailItemLink complete:^(NSError *err, NSString *fullText, NSString *youtubeLink) {
                
                [item setDetailFullText:fullText];
                [item setDetailYoutubeLink:youtubeLink];
                
                [DBMail saveContext:_moc];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                   
                    [self.detailFullTextView setText:item.detailFullText];
                    [self.detailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:item.detailYoutubeLink]]];
                    [self.refreshIndicator stopAnimating];
                });
                

                
            }];
        }
        NSLog(@"%@", arr);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
