//
//  showLocation.m
//  FindMyFriends
//
//  Created by Daniel on 2017/1/4.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "showLocation.h"


@implementation showLocation
- (void)showLocationWithCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate2D mapView:(MKMapView*)mapView {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate2D, span);
    [mapView setRegion:region animated:true];
}
@end
