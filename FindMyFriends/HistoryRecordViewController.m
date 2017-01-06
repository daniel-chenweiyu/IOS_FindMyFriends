//
//  HistoryRecordViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2017/1/4.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "HistoryRecordViewController.h"
#import "Event+CoreDataClass.h"
#import "HistoryRecordTableViewCell.h"

@interface HistoryRecordViewController () <UITableViewDelegate,UITableViewDataSource> {
    CoreDataManagerForEvent * dataManagerForEvent;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    HistoryRecordTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Event * eventItem = (Event*)[dataManagerForEvent getByIndex:indexPath.row];
    cell.titleLabel.text = eventItem.title;
    NSDate * date = [self dateFormatWithDate:eventItem.endTime];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",date];
    cell.infoBtn.tag = indexPath.row;
    [cell.infoBtn addTarget:self action:@selector(showInfoWithBtn:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *item = [dataManagerForEvent getByIndex:indexPath.row];
        [dataManagerForEvent deleteItem:item];
        [dataManagerForEvent saveContextWithCompletion:^(BOOL success) {
            //對tableView做新增刪除的動作記得先update tableView
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
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

- (void) showInfoWithBtn:(UIButton*)sender {
    
    Event * eventItem = (Event*)[dataManagerForEvent getByIndex:sender.tag];
    NSString * startTime = [NSString stringWithFormat:@"%@",[self dateFormatWithDate: eventItem.startTime]];
    NSString * endTime = [NSString stringWithFormat:@"%@",[self dateFormatWithDate: eventItem.endTime]];
    double meter = eventItem.totalMile;
    double km = meter / 1000;
    //    eventItem.startTime eventItem.title
    NSString * message = [NSString stringWithFormat:@"備註：%@\n建立者：%@\n起始時間：%@\n結束時間：%@\n時程：%0.0f sec\n距離：%.03f km",eventItem.descripe,eventItem.userName,startTime,endTime,eventItem.spanTime,km];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:eventItem.title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController* alertEdit = [UIAlertController alertControllerWithTitle:@"編輯" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertEdit addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"事件標題";
            textField.text = eventItem.title;
        }];
        
        [alertEdit addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"備註";
            textField.text = eventItem.descripe;
        }];
        
        UIAlertAction * editSend = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary  * eventDictionary = [NSMutableDictionary new];
            eventDictionary[@"startTime"] = eventItem.startTime;
            eventDictionary[@"id"] = [NSNumber numberWithInt:eventItem.id];
            eventDictionary[@"userName"] = eventItem.userName;
            eventDictionary[@"title"] = alertEdit.textFields.firstObject.text;
            eventDictionary[@"descripe"] = alertEdit.textFields.lastObject.text;
            eventDictionary[@"endTime"] = eventItem.endTime;
            eventDictionary[@"locations"] = eventItem.locations;
            eventDictionary[@"totalMile"] = [NSNumber numberWithDouble:eventItem.totalMile];
            eventDictionary[@"spanTime"] = [NSNumber numberWithInt:eventItem.spanTime];
            CoreDataAction * coreDataAction = [CoreDataAction new];
            [coreDataAction editWithDefault:eventItem dataDictionary:eventDictionary entityName:@"Event" completion:^(bool success, NSManagedObject *result) {
                if (success) {
                    [dataManagerForEvent saveContextWithCompletion:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }];
        }];
        
        UIAlertAction * editCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        [alertEdit addAction:editCancel];
        [alertEdit addAction:editSend];
        [self presentViewController:alertEdit animated:true completion:nil];
    }];
    
    [alert addAction:edit];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

- (NSDate*) dateFormatWithDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate * newDate = [dateFormatter stringFromDate:date];
    return newDate;
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
