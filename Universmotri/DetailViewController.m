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
                
                if (!err) {
                 
                    [item setDetailFullText:fullText];
                    [item setDetailYoutubeLink:youtubeLink];
                    
                    [DBMail saveContext:_moc];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [self.detailFullTextView setText:item.detailFullText];
                        [self.detailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:item.detailYoutubeLink]]];
                        [self.refreshIndicator stopAnimating];
                    });
                } else {
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка!!!"
                                                                                   message:@"Ошибка сети, повторите запрос позднее."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
        NSLog(@"%@", arr);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
