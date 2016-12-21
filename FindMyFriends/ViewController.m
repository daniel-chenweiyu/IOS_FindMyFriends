//
//  ViewController.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/20.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager * locationManager;
    CLLocation * currentLocation ;
    CLLocationCoordinate2D coordinate;
    NSTimer * timer;
}
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        [self updateMyLocation];
        [self getFriendsLocation];
    }
}
-(void)updateMyLocation{
    NSString * lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * name = @"陳威宇";
    NSString * encodename = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * urlString = [NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=ap104&UserName=%@&Lat=%@&Lon=%@",encodename,lat,lon];
    NSURL * url = [NSURL URLWithString:urlString];
    [self sendCommandWithURL:url status:@""];
    
}
-(void)getFriendsLocation{
    NSURL * url = [NSURL URLWithString:@"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=ap104"];
    NSString * status =@"getLoaction";
    [self sendCommandWithURL:url status:status];
}

-(void) sendCommandWithURL: (NSURL*)url status:(NSString*) status{
    NSURLSessionConfiguration * config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@",error);
            return ;
        }
        //        NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //        NSLog(@"JSON: %@",jsonString);
        if ([status isEqualToString:@"getLoaction"]) {
            NSDictionary * dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            NSArray * friendsStatus = dataDictionary[@"friends"];
            if (dataDictionary[@"result"] == false) {
                // Error
            }else{
                // Success
                NSMutableDictionary * friendsDetial = [NSMutableDictionary new];
                for (int i = 0; i < friendsStatus.count; i++) {
                    friendsDetial = friendsStatus[i];
                    if ([friendsDetial[@"friendName"] isEqualToString:@"陳威宇"]) {
                        //if location belong to me don't do anything
                    } else {
                        double lat = [friendsDetial[@"lat"] doubleValue];
                        double lon = [friendsDetial[@"lon"] doubleValue];
                        CLLocationCoordinate2D friendsCoordinate = CLLocationCoordinate2DMake(lat, lon);
                        MKPointAnnotation * annotation = [MKPointAnnotation new];
                        annotation.coordinate = friendsCoordinate;
                        annotation.title = friendsDetial[@"friendName"];
                        annotation.subtitle = friendsDetial[@"lastUpdateDateTime"];
                        //MapView add annotation
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_mainMapView addAnnotation:annotation];
                        });
                    }
                }
            }
        }
    }];
    [task resume];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
