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
#import "NetworkHelper.h"

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
    
    self.uidNews = self.tabBarItem.tag;
    
    [[DBMail sharedInstance] initWithCompletionBlock:^(BOOL success) {
        
        NSManagedObjectContext *moc = [DBMail mocPerThread];
        
        [moc performBlock:^{
            
            if ([DBMail objectWithEntity:@"Item" param:@{@"uidNews" : [NSNumber numberWithInt:(int)self.tabBarItem.tag]} sort:nil offset:0 limit:0 MOC:moc].count > 0) {
            
                NSLog(@"%@", [NSNumber numberWithInt:(int)self.tabBarItem.tag]);
                
                [self updateTable];
                
            } else {
                
                NSLog(@"%i", (int)self.tabBarItem.tag);
                [NetworkHelper getNewsForType:(int)self.tabBarItem.tag complete:^(NSError *err) {
                    
                    [NetworkHelper downloadAllImages:self.uidNews];
                    [self updateTable];
                    NSLog(@"====>%@", err);
                }];
            }
        }];
        NSLog(@"DB_INIT");
    }];
}

-(void)updateTable {
    
    [self updateSort];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.newsTableView reloadData];
    });
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
    
    if (item.itemImage) {
        
        [[(NewsTableViewCell *)cell2 tittleImage] setImage:[UIImage imageWithData:item.itemImage]];
    } else {
        
        //default
    }

    [[(NewsTableViewCell *)cell2 tittleLabel] setText:item.itemTittle];
    NSArray* words = [item.itemTime componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@" "];

    [[(NewsTableViewCell *)cell2 timeLabel] setText:nospacestring];
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

#pragma mark - table

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.newsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.newsTableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            if ([[controller sections] count] > 0)
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = self.newsTableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            NSLog(@"upd");
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.newsTableView endUpdates];
}

@end
