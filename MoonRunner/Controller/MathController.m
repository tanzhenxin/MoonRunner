//
//  MathController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "MathController.h"
#import "Location.h"
#import "MultiColorPolylineSegment.h"

static bool const isMetric = YES;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;

@implementation MathController

+ (NSString *)stringifyDistance:(float)meters {
    NSString *unitName;
    float unitDevider;
    
    if (isMetric) {
        unitName = @"km";
        unitDevider = metersInKM;
    } else {
        unitName = @"mi";
        unitDevider = metersInMile;
    }
    return [NSString stringWithFormat:@"%.2f %@", (meters / unitDevider), unitName];
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat {
    int remaingSeconds = seconds;
    int hours = seconds / 3600;
    remaingSeconds = remaingSeconds - hours * 3600;
    int minutes = seconds / 60;
    remaingSeconds = remaingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, seconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, seconds];
        } else {
            return [NSString stringWithFormat:@"%isec", seconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
        } else {
            return [NSString stringWithFormat:@"00:%02i", seconds];
        }
    }
}

+ (NSString *)stringifyAvgPaceFromDict:(float)meters overTime:(int)seconds {
    if (meters == 0 || seconds == 0) {
        return @"0";
    }
    
    float avgPaceSecMeters = seconds / meters;
    
    NSString *unitName;
    float unitMultiplier;
    
    if (isMetric) {
        unitName = @"min/km";
        unitMultiplier = metersInKM;
    } else {
        unitName = @"min/mi";
        unitMultiplier = metersInMile;
    }
    
    int paceMin = (int)((avgPaceSecMeters * unitMultiplier) / 60);
    int paceSec = (int)(avgPaceSecMeters * unitMultiplier - (paceMin * 60));
                        
    return [NSString stringWithFormat:@"%i:%02i %@", paceMin, paceSec, unitName];
}

+ (NSArray *)colorSegmentForLocations:(NSArray *)locations {
    NSMutableArray *speeds = [NSMutableArray array];
    double minSpeed = DBL_MAX;
    double maxSpeed = 0.0;
    
    for (int i = 1; i < locations.count; i++) {
        Location *lastLoc = [locations objectAtIndex:(i - 1)];
        Location *thisLoc = [locations objectAtIndex:i];
        
        CLLocation *lastLocCL = [[CLLocation alloc] initWithLatitude:lastLoc.latitude.doubleValue
                                                           longitude:lastLoc.langitude.doubleValue];
        CLLocation *thisLocCL = [[CLLocation alloc] initWithLatitude:thisLoc.latitude.doubleValue
                                                           longitude:thisLoc.langitude.doubleValue];
        
        double distance = [lastLocCL distanceFromLocation:thisLocCL];
        double time = [lastLoc.timstamp timeIntervalSinceDate:thisLoc.timstamp];
        double speed = distance / time;
        
        minSpeed = speed < minSpeed ? speed : minSpeed;
        maxSpeed = speed > maxSpeed ? speed : maxSpeed;
        
        [speeds addObject:@(speed)];
    }
    
    // now knowing the slowest+fastest, we can get mean too
    double meanSpeed = (minSpeed + maxSpeed) / 2;
    
    // RGB for red (slowest)
    CGFloat r_red = 1.0f;
    CGFloat r_green = 20/255.0f;
    CGFloat r_blue = 44/255.0f;
    
    // RGB for yellow (middle)
    CGFloat y_red = 1.0f;
    CGFloat y_green = 215/255.0f;
    CGFloat y_blue = 0.0f;
    
    // RGB for green (fastest)
    CGFloat g_red = 0.0f;
    CGFloat g_green = 146/255.0f;
    CGFloat g_blue = 78/255.0f;
    
    NSMutableArray *colorSegments = [NSMutableArray array];
    
    for (int i = 1; i < locations.count; ++i) {
        Location *lastLoc = [locations objectAtIndex:(i - 1)];
        Location *thisLoc = [locations objectAtIndex:i];
        
        CLLocationCoordinate2D coords[2];
        coords[0].latitude = lastLoc.latitude.doubleValue;
        coords[0].longitude = lastLoc.langitude.doubleValue;
        
        coords[1].latitude = thisLoc.latitude.doubleValue;
        coords[1].longitude = thisLoc.langitude.doubleValue;
        
        NSNumber *speed = [speeds objectAtIndex:(i - 1)];
        UIColor *color = [UIColor blackColor];
        // between red and yellow
        if (speed.doubleValue < meanSpeed) {
            double ratio = (speed.doubleValue - minSpeed) / (meanSpeed - maxSpeed);
            CGFloat red = r_red + ratio * (y_red - r_red);
            CGFloat green = r_green + ratio * (y_green - r_green);
            CGFloat blue = r_blue + ratio * (y_blue - r_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            // between yellow and green
        } else {
            double ratio = (speed.doubleValue - meanSpeed) / (maxSpeed - meanSpeed);
            CGFloat red = y_red + ratio * (g_red - y_red);
            CGFloat green = y_green + ratio * (g_green - y_green);
            CGFloat blue = y_blue + ratio * (g_blue - y_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        }
        
        MultiColorPolylineSegment *segment = [MultiColorPolylineSegment polylineWithCoordinates:coords count:2];
        segment.color = color;
        [colorSegments addObject:segment];
    }
    
    return colorSegments;
}

@end
