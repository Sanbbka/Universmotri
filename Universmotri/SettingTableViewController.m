//
//  SettingTableViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 26.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "SettingTableViewController.h"
#import "DetailSettingTableViewController.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController
{
    NSArray *settings;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    settings = @[@{@"streamQuality" : @"Качество стрима"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    NSDictionary *setDict = settings[indexPath.row];
    [cell.textLabel setText:[setDict valueForKey:[setDict.allKeys objectAtIndex:indexPath.row]]];
    [cell.detailTextLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:[setDict.allKeys objectAtIndex:indexPath.row]]?: @"Не выбрано"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSDictionary *setDict = settings[self.tableView.indexPathForSelectedRow.row];
    DetailSettingTableViewController *detailVC = [segue destinationViewController];
    [detailVC setSetArr:@[@"Низкое", @"Среднее", @"Высокое"]];
    [detailVC setKey:[setDict.allKeys objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
//    [detailVC.navigationItem setTitle:[setDict valueForKey:[setDict.allKeys objectAtIndex:self.tableView.indexPathForSelectedRow.row]]];
}

@end
