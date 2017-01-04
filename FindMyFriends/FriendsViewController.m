//
//  FriendsViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2017/1/3.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "FriendsViewController.h"
#import "Friends+CoreDataClass.h"

@interface FriendsViewController ()<UITableViewDelegate, UITableViewDataSource> {
CoreDataManager * dataManager;    
}

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        dataManager = [CoreDataManager sharedInstance];
    [dataManager prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"friendName" entityName:@"Friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataManager.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Friends * item = (Friends*)[dataManager getByIndex:indexPath.row];
    cell.textLabel.text = item.friendName;
    cell.detailTextLabel.text = item.lastUpdateDateTime;
    
    return cell;
}
- (IBAction)backBtb:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
