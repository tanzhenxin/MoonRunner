//
//  WGS84TOGCJ02.h
//  MoonRunner
//
//  Created by 檀振兴 on 7/9/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WGS84TOGCJ02 : NSObject

+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end
