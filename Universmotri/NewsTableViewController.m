//
//  NewsTableViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 04.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "NewsTableViewController.h"
#import "DBMail.h"
#import "Item.h"
#import "DownloadItems.h"
#import "NewsTableViewCell.h"

@interface NewsTableViewController()<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation NewsTableViewController

NSString *reuseIdent2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    reuseIdent2 = @"newsCell";
    
    [[DBMail sharedInstance] initWithCompletionBlock:^(BOOL success) {
        
        NSManagedObjectContext *moc = [DBMail mocPerThread];
        
        [moc performBlock:^{
            
            if ([DBMail objectWithEntity:@"Item" param:nil sort:nil offset:0 limit:0 MOC:moc].count > 0) {
            
                [self updateSort];
                [self.tableView reloadData];
            } else {
                
                
            }

        }];
        
        NSLog(@"DB_INIT");
        
    }];
}

- (void)updateSort {
    
    NSFetchRequest *fetchRequest;
    if (self.fetchedResultsController == nil)
    {
        self.managedObjectContext = [DBMail mocMain];
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    }
    else
        fetchRequest = self.fetchedResultsController.fetchRequest;
    
    
    // фильтр
    NSMutableArray *preds = [NSMutableArray new];
    
    [preds addObject: [NSPredicate predicateWithFormat:@"(uidNews == %i)",  self.uidNews]];
    if (preds.count > 0)
    {
        NSPredicate  *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
        [fetchRequest setPredicate:predicate];
    }
    else
        [fetchRequest setPredicate:nil];

    
    // сортировка
    NSMutableArray *sorts = [NSMutableArray new];
    
//    [sorts addObject:[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES]];
    //    [sorts addObject:[[NSSortDescriptor alloc] initWithKey:@"countMsgs" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ];
    [fetchRequest setSortDescriptors:sorts];
    [fetchRequest setFetchBatchSize:20];
    
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:self.managedObjectContext
                                                                                                    sectionNameKeyPath:nil                                                                                                                 cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell2 atIndexPath:(NSIndexPath *)indexPath {
    Item *item = [_fetchedResultsController objectAtIndexPath:indexPath];

    [[(NewsTableViewCell *)cell2 tittleLabel] setText:item.itemTittle];
    [[(NewsTableViewCell *)cell2 timeLabel] setText:item.itemTime];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:reuseIdent2];
    
    [((UILabel*)[cell2 viewWithTag:2]).layer setCornerRadius:15.];
    [((UILabel*)[cell2 viewWithTag:2]).layer setMasksToBounds:YES];
    [cell2 setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1]];
    UIView *BGViewColor = [UIView new];
    BGViewColor.backgroundColor = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
    BGViewColor.layer.masksToBounds = true;
    cell2.selectedBackgroundView = BGViewColor;
    
    [self configureCell:cell2 atIndexPath:indexPath];
    
    return cell2;
}


@end
