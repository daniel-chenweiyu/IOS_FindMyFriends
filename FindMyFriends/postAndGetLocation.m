//
//  postAndGetLocation.m
//  FindMyFriends
//
//  Created by Daniel on 2016/12/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "postAndGetLocation.h"
#import "Friends+CoreDataClass.h"



@implementation postAndGetLocation {
    CoreDataManager * dataManager;
    CoreDataAction * coreDataAction;
    NSString * entityName;
}
//-(void)startUpdateAndGetWithCLLocation:(CLLocation*) currentLocation CLLocationCoordinate2D:(CLLocationCoordinate2D) coordinate{
//    if (currentLocation != nil) {
//        [self updateMyLocation];
//        [self getFriendsLocation];
//    }
//}
- (void)updateMyLocation:(CLLocationCoordinate2D) coordinate userName:(NSString*) userName {
    
    NSString * lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString * encodeName = [userName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * urlString = [NSString stringWithFormat:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=ap104&UserName=%@&Lat=%@&Lon=%@",encodeName,lat,lon];
    NSURL * url = [NSURL URLWithString:urlString];
    [self sendCommandWithURL:url status:nil mapView:nil userName:nil showOrHideAnnotation:nil];
    
}

- (void)getFriendsLocation:(MKMapView*) mainMapView userName:(NSString*) userName showOrHideAnnotation:(NSString*) showOrHideAnnotation {
    
    //set dataManager
    coreDataAction = [CoreDataAction new];
    entityName = @"Friends";
    dataManager = [coreDataAction coreDataManagerSettingWithEntityName:entityName];
    NSURL * url = [NSURL URLWithString:@"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=ap104"];
    NSString * status = @"getLoaction";
    [self sendCommandWithURL:url status:status mapView:mainMapView userName:userName showOrHideAnnotation:showOrHideAnnotation];
}

- (void)sendCommandWithURL: (NSURL*)url status:(NSString*) status mapView:(MKMapView*) mainMapView userName:(NSString*) userName showOrHideAnnotation:(NSString*) showOrHideAnnotation {
    
    NSURLSessionConfiguration * config =[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@",error);
            return ;
        }
        // check isn't getFriendsLocation method
        if ([status isEqualToString:@"getLoaction"]) {
            NSDictionary * dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            NSArray * friendsStatus = dataDictionary[@"friends"];
            // remove old annotations
            [mainMapView removeAnnotations:mainMapView.annotations] ;
            if (dataDictionary[@"result"] == false) {
                // Error
            }else{
                // Success
                NSMutableDictionary * friendsDetial = [NSMutableDictionary new];
                for (int i = 0; i < friendsStatus.count; i++) {
                    NSManagedObject *object = nil;
                    friendsDetial = friendsStatus[i];
                    // don't show myself annotation
                    if ([friendsDetial[@"friendName"] isEqualToString:userName]) {
                        //if location belong to me don't do anything
                    } else {
                        //check friends are already in DB yet
                        for(int j = 0 ; j < dataManager.count ; j++) {
                            Friends * item = (Friends*)[dataManager getByIndex:j];
                            if ([item.friendName isEqualToString:friendsDetial[@"friendName"]]) {
                                object = [dataManager getByIndex:j];
                                break;
                            }
                        }
                        [coreDataAction editWithDefault:object dataDictionary:friendsDetial entityName:entityName completion:^(bool success, NSManagedObject *result) {
                            if (success) {
                                [dataManager saveContextWithCompletion:^(BOOL success) {
                                    [self addAnnotationWithMapView:mainMapView managedObject:result showOrHideAnnotation:showOrHideAnnotation];
                                }];
                            }
                        }];
                    }
                }
            }
        }
    }];
    [task resume];
}

- (void)addAnnotationWithMapView:(MKMapView*)mainMapView managedObject:(NSManagedObject*)result showOrHideAnnotation:(NSString*) showOrHideAnnotation {
    
    double lat = [[result valueForKey:@"lat"] doubleValue];
    double lon = [[result valueForKey:@"lon"] doubleValue];
    CLLocationCoordinate2D friendsCoordinate = CLLocationCoordinate2DMake(lat, lon);
    MKPointAnnotation * annotation = [MKPointAnnotation new];
    annotation.coordinate = friendsCoordinate;
    annotation.title = [result valueForKey:@"friendName"];
    annotation.subtitle = [result valueForKey:@"lastUpdateDateTime"];
    //MapView add annotation
    EditViewController * editViewController = [EditViewController new];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainMapView addAnnotation:annotation];
        [editViewController showOrHideAnnotationWithMapView:mainMapView];
    });
}

@end
