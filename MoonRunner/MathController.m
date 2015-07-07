//
//  MathController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "MathController.h"

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

@end
