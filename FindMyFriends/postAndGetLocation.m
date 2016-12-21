//
//  postAndGetLocation.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "postAndGetLocation.h"


@implementation postAndGetLocation
//-(void)startUpdateAndGetWithCLLocation:(CLLocation*) currentLocation CLLocationCoordinate2D:(CLLocationCoordinate2D) coordinate{
//    if (currentLocation != nil) {
//        [self updateMyLocation];
//        [self getFriendsLocation];
//    }
//}
-(void)updateMyLocation:(CLLocationCoordinate2D) coordinate{
    NSString * lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * name = @"陳威宇";
    NSString * encodename = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * urlString = [NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=ap104&UserName=%@&Lat=%@&Lon=%@",encodename,lat,lon];
    NSURL * url = [NSURL URLWithString:urlString];
    [self sendCommandWithURL:url status:@"" mapView:nil];
    
}
-(void)getFriendsLocation:(MKMapView*) mainMapView{
    NSURL * url = [NSURL URLWithString:@"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=ap104"];
    NSString * status =@"getLoaction";
    [self sendCommandWithURL:url status:status mapView:mainMapView];
}

-(void) sendCommandWithURL: (NSURL*)url status:(NSString*) status mapView:(MKMapView*) mainMapView{
    NSURLSessionConfiguration * config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@",error);
            return ;
        }
        if ([status isEqualToString:@"getLoaction"]) {
            NSDictionary * dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            NSArray * friendsStatus = dataDictionary[@"friends"];
            //remove old annotations
            [mainMapView removeAnnotations:mainMapView.annotations] ;
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
                            [mainMapView addAnnotation:annotation];
                            
                        });
                    }
                }
            }
        }
    }];
    [task resume];
}


@end
