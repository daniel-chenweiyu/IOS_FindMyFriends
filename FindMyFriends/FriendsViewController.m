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
    NSUserDefaults * userDefaults;
    NSArray * thisAppEdit;
}

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CoreDataAction * coreDataAction = [CoreDataAction new];
    NSString * entityName = @"Friends";
    dataManager = [coreDataAction coreDataManagerSettingWithEntityName:entityName];
    userDefaults = [NSUserDefaults standardUserDefaults];
    thisAppEdit = [userDefaults objectForKey:@"findMyFriendsEdit"];
    // check DB if has userInfo then delete Info
    [self checkCoreDatahasUserInformation];
}

- (void)checkCoreDatahasUserInformation {
    
    for (int i = 0; i < dataManager.count; i++) {
        Friends * item = (Friends*)[dataManager getByIndex:i];
        if ([item.friendName isEqualToString:thisAppEdit[0]]) {
            [dataManager deleteItem:item];
            [dataManager saveContextWithCompletion:nil];
        }
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated:true completion:nil];
    showLocation * showFriendsLocation = [showLocation new];
    CLLocationCoordinate2D coordinate;
    Friends * item = (Friends*)[dataManager getByIndex:indexPath.row];
    coordinate.latitude = [item.lat floatValue];
    coordinate.longitude = [item.lon floatValue];
    [showFriendsLocation showLocationWithCLLocationCoordinate2D:coordinate mapView:_mainMapView];
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
