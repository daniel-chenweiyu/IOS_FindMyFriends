//
//  ViewController.h
//  FindMyFriends
//
//  Created by Daniel on 2016/12/20.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "EditViewController.h"
#import "CoreDataManager.h"
#import "postAndGetLocation.h"
#import "CoreDataAction.h"
#import "FriendsViewController.h"
#import "MapViewAction.h"
#import "HistoryRecordViewController.h"
#import "CoreDataManagerForEvent.h"

@interface ViewController : UIViewController
-(void)userDefaultsSetting;

@end

