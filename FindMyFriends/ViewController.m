//
//  ViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/20.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "postAndGetLocation.h"

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager * locationManager;
    CLLocation * currentLocation ;
    CLLocationCoordinate2D coordinate;
    NSTimer * timer;
    postAndGetLocation * postGetLocation ;
}
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    postGetLocation = [postAndGetLocation new];
    //set locationManager
    locationManager = [CLLocationManager new];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = kCLLocationAccuracyBestForNavigation;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}
- (IBAction)mapTypeChange:(UISegmentedControl *)sender {
    NSInteger targetIndex = [sender selectedSegmentIndex];
    switch (targetIndex) {
        case 0:
            _mainMapView.mapType = MKMapTypeStandard;
            break;
        case 1 :
            _mainMapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mainMapView.mapType = MKMapTypeHybrid;
            break;
    }
}
- (IBAction)userTrackingModeChanged:(UISegmentedControl *)sender {
    NSInteger targetIndex = [sender selectedSegmentIndex];
    switch (targetIndex) {
            
        case 0:
            _mainMapView.userTrackingMode = MKUserTrackingModeNone;
            break;
        case 1:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case 2:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            break;
            
    }
}
- (IBAction)showUserLocationBtn:(UIButton *)sender {
    [self showMyLocation];
}
- (IBAction)recordBtn:(UIButton *)sender {
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
        //every 60s start update my loaction to server and get friends location from server
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startUpdateAndGet) userInfo:nil repeats:YES];
    });
}

-(void)showMyLocation{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [_mainMapView setRegion:region animated:true];
}
-(void)startUpdateAndGet{
    if (currentLocation != nil) {
        [postGetLocation updateMyLocation:coordinate];
        [postGetLocation getFriendsLocation:_mainMapView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
