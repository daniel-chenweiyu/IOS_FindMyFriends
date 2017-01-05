//
//  HistoryRecordViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2017/1/4.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "HistoryRecordViewController.h"
#import "Event+CoreDataClass.h"

@interface HistoryRecordViewController () <UITableViewDelegate,UITableViewDataSource> {
    CoreDataManagerForEvent * dataManagerForEvent;
}

@end

@implementation HistoryRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CoreDataAction * coreDataAction = [CoreDataAction new];
    NSString * entityName = @"Event";
    dataManagerForEvent = [coreDataAction coreDataManagerForEventSettingWithEntityName:entityName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataManagerForEvent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Event * item = (Event*)[dataManagerForEvent getByIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",item.endTime];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated:true completion:nil];
    MapViewAction * showFriendsLocation = [MapViewAction new];
    CLLocationCoordinate2D coordinate;
    Event * item = (Event*)[dataManagerForEvent getByIndex:indexPath.row];
    NSArray * locations = item.locations;
    CLLocation * currentLocation = locations[0];
    coordinate = currentLocation.coordinate;
    [showFriendsLocation showLocationWithCLLocationCoordinate2D:coordinate mapView:_mainMapView];
    [showFriendsLocation drawLineWithArray:locations mapView:self.mainMapView];
}

- (IBAction)backBtn:(UIBarButtonItem *)sender {
    
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
