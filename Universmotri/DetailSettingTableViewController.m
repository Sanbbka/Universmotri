//
//  DetailSettingTableViewController.m
//  Universmotri
//
//  Created by Alexander Drovnyashin on 27.01.16.
//  Copyright © 2016 Alexander Drovnyashin. All rights reserved.
//

#import "DetailSettingTableViewController.h"

@interface DetailSettingTableViewController ()

@end

@implementation DetailSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem.leftBarButtonItem setTitle:@"Назад"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _setArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCellDetail" forIndexPath:indexPath];
    
    [cell.textLabel setText:_setArr[indexPath.row]];
       
    return cell;
}

@end
