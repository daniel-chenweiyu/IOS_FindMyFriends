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
-(void)updateMyLocation:(CLLocationCoordinate2D) coordinate userName:(NSString*) userName{
    NSString * lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * encodeName = [userName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * urlString = [NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=ap104&UserName=%@&Lat=%@&Lon=%@",encodeName,lat,lon];
    NSURL * url = [NSURL URLWithString:urlString];
    [self sendCommandWithURL:url status:@"" mapView:nil userName:nil showOrHideAnnotation:nil];
    
}
-(void)getFriendsLocation:(MKMapView*) mainMapView userName:(NSString*) userName showOrHideAnnotation:(NSString*) showOrHideAnnotation{
    NSURL * url = [NSURL URLWithString:@"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=ap104"];
    NSString * status =@"getLoaction";
    [self sendCommandWithURL:url status:status mapView:mainMapView userName:userName showOrHideAnnotation:showOrHideAnnotation];
}

-(void) sendCommandWithURL: (NSURL*)url status:(NSString*) status mapView:(MKMapView*) mainMapView userName:(NSString*) userName showOrHideAnnotation:(NSString*) showOrHideAnnotation{
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
                    // don't show myself annotation
                    if ([friendsDetial[@"friendName"] isEqualToString:userName]) {
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
                            for (id annotation in mainMapView.annotations) {
                                if (annotation != mainMapView.userLocation) {
                                    if (![showOrHideAnnotation  isEqual: @"1"]) {
                                        [[mainMapView viewForAnnotation:annotation] setHidden:YES];
                                    }
                                }
                            }
                            //                            if (![showOrHideAnnotation  isEqual: @"1"]) {
                            //                                [[mainMapView viewForAnnotation:annotation] setHidden:YES];
                            //                            }
                        });
                    }
                }
            }
        }
    }];
    [task resume];
}


@end
