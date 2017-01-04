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
}
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UIButton *userTrackingModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopRecordBtn;


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
}

-(void)viewDidAppear:(BOOL)animated{
    //start update my loaction to server and get friends location from server
    timer = [NSTimer scheduledTimerWithTimeInterval:[thisAppEdit[3] intValue] target:self selector:@selector(startUpdateAndGet) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
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
    }else{
        [_startAndStopRecordBtn setImage:[UIImage imageNamed:@"run"] forState:UIControlStateNormal];
        recordTarget = false;
    }
}

#pragma mark - CLLocationManagerDelegate Methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    currentLocation = locations.lastObject;
    coordinate = currentLocation.coordinate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self showMyLocation];
        //do first startUpdateAndGet
        [self startUpdateAndGet];
        //        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startUpdateAndGet) userInfo:nil repeats:YES];
    });
}

-(void)showMyLocation{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [_mainMapView setRegion:region animated:true];
}

-(void)startUpdateAndGet{
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditViewController * editViewController = segue.destinationViewController;
    editViewController.mainMapView = _mainMapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
