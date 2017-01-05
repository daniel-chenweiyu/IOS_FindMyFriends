//
//  ViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/20.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate> {
    CLLocationManager * locationManager;
    CLLocation * currentLocation ;
    CLLocationCoordinate2D coordinate;
    NSTimer * timer;
    postAndGetLocation * postGetLocation ;
    NSInteger targetIndex;
    BOOL recordTarget;
    NSUserDefaults * userDefaults;
    NSMutableArray * thisAppEdit;
    CoreDataManager * dataManager;
    CoreDataAction * coreDataAction;
    MapViewAction * mapViewAction;
    MKPolylineView * lineView;
    NSMutableDictionary * eventDictionary;
    NSMutableArray * coordinateArray;
    int count;
}
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UIButton *userTrackingModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopRecordBtn;
@property (weak, nonatomic) IBOutlet UILabel *barLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set userDefault
    [self userDefaultsSetting];
    //set userTrackingModeChange begin MKUserTrackingModeNone
    targetIndex = 0 ;
    recordTarget = false;
    postGetLocation = [postAndGetLocation new];
    //set locationManager
    [self locationManagerSetting];
    //set coreData
    coreDataAction = [CoreDataAction new];
    //set drowLineArray
    mapViewAction = [MapViewAction new];
    coordinateArray = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated {
    // start update my loaction to server and get friends location from server
    timer = [NSTimer scheduledTimerWithTimeInterval:[thisAppEdit[3] intValue] target:self selector:@selector(startUpdateAndGet) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [timer invalidate];
    timer = nil;
}

-(void)locationManagerSetting {
    if (locationManager == nil) {
        locationManager = [CLLocationManager new];
    }
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = kCLLocationAccuracyBestForNavigation;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

-(void)userDefaultsSetting {
    if (userDefaults == nil) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    NSArray * data = [userDefaults objectForKey:@"findMyFriendsEdit"];
    if (data != nil) {
        thisAppEdit = [NSMutableArray arrayWithArray:data];
    }else{
        thisAppEdit = [NSMutableArray new];
        //userName(update to server name)
        thisAppEdit[0] = @"預設使用者";
        //allow update location to server
        thisAppEdit[1] = @"1";
        //allow download friends loaction from server
        thisAppEdit[2] = @"1";
        //frequency about update and download (for sec)
        thisAppEdit[3] = @"60";
        //hidding friends annotation
        thisAppEdit[4] = @"1";
        [userDefaults setObject:thisAppEdit forKey:@"findMyFriendsEdit"];
        [userDefaults synchronize];
        NSNumber * eventId = @(0);
        [userDefaults setObject:eventId forKey:@"eventId"];
        [userDefaults synchronize];
    }
}

- (IBAction)userTrackingModeChangedBtn:(UIButton *)sender {
    //defaul targetIndex = 0 so first press should be 1
    targetIndex++ ;
    if (targetIndex >= 3) {
        targetIndex = 0;
    }
    switch (targetIndex) {
        case 0:
            _mainMapView.userTrackingMode = MKUserTrackingModeNone;
            [_userTrackingModeBtn setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
            break;
        case 1:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollow;
            [_userTrackingModeBtn setImage:[UIImage imageNamed:@"trace"] forState:UIControlStateNormal];
            break;
        case 2:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            [_userTrackingModeBtn setImage:[UIImage imageNamed:@"traceAndDirection"] forState:UIControlStateNormal];
            break;
    }
}

- (IBAction)recordBtn:(UIButton *)sender {
    if (recordTarget == false) {
        [_startAndStopRecordBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        recordTarget = true;
        self.barLabel.text = @"紀錄中";
        //add new eventDictionary
        eventDictionary = [NSMutableDictionary new];
        eventDictionary[@"startTime"] = [NSDate date];
    }else{
        [_startAndStopRecordBtn setImage:[UIImage imageNamed:@"run"] forState:UIControlStateNormal];
        recordTarget = false;
        self.barLabel.text = @"記錄完成";
        // take eventId from userDefaults
        NSNumber * eventId = [userDefaults objectForKey:@"eventId"];
        eventDictionary[@"id"] = eventId;
        eventDictionary[@"userName"] = thisAppEdit[0];
        eventDictionary[@"title"] = [NSString stringWithFormat:@"軌跡記錄(%@)",eventId];
        eventDictionary[@"descripe"] = @"";
        eventDictionary[@"endTime"] = [NSDate date];
        eventDictionary[@"locations"] = coordinateArray;
        CLLocationDistance distanceInMeters;
        for (int i = 0 ; i < coordinateArray.count - 1; i++) {
            distanceInMeters += [coordinateArray[i] distanceFromLocation:coordinateArray[i + 1]];
        }
        NSNumber * totalMile = [NSNumber numberWithDouble:distanceInMeters];
        eventDictionary[@"totalMile"] = totalMile;
        NSTimeInterval sec = [eventDictionary[@"endTime"] timeIntervalSinceDate:eventDictionary[@"startTime"]];
        NSNumber * timeSpan = [NSNumber numberWithInt:sec];
        eventDictionary[@"spanTime"] = timeSpan;
        eventId = [NSNumber numberWithInt:([eventId intValue] + 1)];
        [userDefaults setObject:eventId forKey:@"eventId"];
        [userDefaults synchronize];
        NSString * entityName = @"Event";
        CoreDataManagerForEvent * dataManagerForEvent = [coreDataAction coreDataManagerForEventSettingWithEntityName:entityName];
        [coreDataAction editWithDefault:nil dataDictionary:eventDictionary entityName:entityName completion:^(bool success, NSManagedObject *result) {
            [dataManagerForEvent saveContextWithCompletion:nil];
        }];
    }
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    currentLocation = locations.lastObject;
    coordinate = currentLocation.coordinate;
    if (recordTarget) {
        coordinateArray[count] = currentLocation;
        [mapViewAction drawLineWithArray:coordinateArray mapView:self.mainMapView];
        count++;
    } else {
        count = 0;
        coordinateArray = [NSMutableArray new];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MapViewAction * showMyLocation = [MapViewAction new];
        [showMyLocation showLocationWithCLLocationCoordinate2D:coordinate mapView:_mainMapView];
        //do first startUpdateAndGet
        [self startUpdateAndGet];
    });
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    lineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    lineView.strokeColor = [UIColor redColor];
    lineView.lineWidth = 5;
    return lineView;
}

- (void)startUpdateAndGet {
    [self userDefaultsSetting];
    if (currentLocation != nil) {
        if ([thisAppEdit[1]  isEqual: @"1"]) {
            [postGetLocation updateMyLocation:coordinate userName:thisAppEdit[0]];
        }
        if ([thisAppEdit[2]  isEqual: @"1"]) {
            [postGetLocation getFriendsLocation:_mainMapView userName:thisAppEdit[0] showOrHideAnnotation:thisAppEdit[4]];
        }
    }
}

- (IBAction)goToEditView:(UIButton *)sender {
    
    EditViewController * editViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditViewController"];
    editViewController.mainMapView = _mainMapView;
    [self showViewController:editViewController sender:self];
}

- (IBAction)goToFriednsView:(UIButton *)sender {
    
    FriendsViewController * editViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
    editViewController.mainMapView = _mainMapView;
    [self showViewController:editViewController sender:self];
}

- (IBAction)goToHistoryRecordView:(UIButton *)sender {
    
    HistoryRecordViewController * historyRecordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryRecordViewController"];
    historyRecordViewController.mainMapView = _mainMapView;
    [self showViewController:historyRecordViewController sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
