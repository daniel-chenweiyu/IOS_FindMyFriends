//
//  postAndGetLocation.h
//  FindMyFriends
//
//  Created by Daniel on 2016/12/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface postAndGetLocation : NSObject
//-(void)startUpdateAndGetWithCLLocation:(CLLocation*) currentLocation CLLocationCoordinate2D:(CLLocationCoordinate2D) coordinate;
-(void)updateMyLocation:(CLLocationCoordinate2D) coordinate userName:(NSString*) userName;
-(void)getFriendsLocation:(MKMapView*) mainMapView userName:(NSString*) userName showOrHideAnnotation:(NSString*) showOrHideAnnotation;
@end
