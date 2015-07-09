//
//  BadgeController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BadgeController.h"
#import "Badge.h"
#import "BadgeEarnStatus.h"
#import "Run.h"
#import "Location.h"
#import "BadgeAnnotation.h"

float const silverMultiplier = 1.05f;
float const goldMultiplier = 1.10f;

@interface BadgeController ()

@property (strong, nonatomic) NSArray *badges;

@end

@implementation BadgeController

+ (BadgeController *)defaultController {
    static BadgeController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [BadgeController new];
        controller.badges = [self badgeArray];
    });
    
    return controller;
}

+ (NSArray *)badgeArray {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"badges" ofType:@"txt"];
    NSString *jsonContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *badgeDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSMutableArray *badges = [NSMutableArray array];
    for (NSDictionary *dict in badgeDicts) {
        Badge *badge = [self badgeFromDictionary:dict];
        [badges addObject:badge];
    }
    
    return badges;
}

+ (Badge *)badgeFromDictionary:(NSDictionary *)dict {
    Badge *badge = [Badge new];
    badge.name = [dict objectForKey:@"name"];
    badge.imageName = [dict objectForKey:@"imageName"];
    badge.information = [dict objectForKey:@"information"];
    badge.distance = [[dict objectForKey:@"distance"] floatValue];
    return badge;
}

- (NSArray *)earnStatusedForRuns:(NSArray *)runArray {
    NSMutableArray *earnedArray = [NSMutableArray array];
    
    for (Badge *badge in self.badges) {
        BadgeEarnStatus *earnStatus = [BadgeEarnStatus new];
        earnStatus.badge = badge;
        
        for (Run *run in runArray) {
            if (run.distance.floatValue > badge.distance) {
                if (!earnStatus.earnRun) {
                    earnStatus.earnRun = run;
                }
                
                double earnSpeed = earnStatus.earnRun.distance.doubleValue / earnStatus.earnRun.duration.doubleValue;
                double runSpeed = run.distance.doubleValue / run.duration.doubleValue;
                
                if (!earnStatus.silverRun && runSpeed > earnSpeed * silverMultiplier) {
                    earnStatus.silverRun = run;
                }
                if (!earnStatus.goldRun && runSpeed > earnSpeed * goldMultiplier) {
                    earnStatus.goldRun = run;
                }
                
                if (!earnStatus.bestRun) {
                    earnStatus.bestRun = run;
                } else {
                    double bestSpeed = earnStatus.bestRun.distance.doubleValue / earnStatus.bestRun.duration.doubleValue;
                    if (runSpeed > bestSpeed) {
                        earnStatus.bestRun = run;
                    }
                }
            }
        }
        
        [earnedArray addObject:earnStatus];
    }
    
    return earnedArray;
}

- (Badge *)bestBadgeForDistance:(float)distance {
    Badge *bestBadge = self.badges.firstObject;
    for (Badge *badge in self.badges) {
        if (distance < badge.distance) {
            break;
        }
        bestBadge = badge;
    }
    
    return bestBadge;
}   

- (Badge *)nextBadgeForDistance:(float)distance {
    Badge *nextBadge;
    for (Badge *badge in self.badges) {
        nextBadge = badge;
        if (distance < nextBadge.distance) {
            break;
        }
    }
    
    return nextBadge;
}

- (NSArray *)mapAnnotationsForRun:(Run *)run {
    NSMutableArray *annotations = [NSMutableArray array];
    
    double distance = 0;
    int locationIndex = 1;
    
    for (Badge *badge in self.badges) {
        if (run.distance.doubleValue < badge.distance) {
            break;
        }
        
        while (locationIndex < run.locations.count) {
            Location *lastLoc = [run.locations objectAtIndex:(locationIndex - 1)];
            Location *thisLoc = [run.locations objectAtIndex:locationIndex];
            
            CLLocation *lastLocCL = [[CLLocation alloc] initWithLatitude:lastLoc.latitude.doubleValue longitude:lastLoc.langitude.doubleValue];
            CLLocation *thisLocCL = [[CLLocation alloc] initWithLatitude:thisLoc.latitude.doubleValue longitude:thisLoc.langitude.doubleValue];
            
            distance += [lastLocCL distanceFromLocation:thisLocCL];
            locationIndex++;
            
            if (distance > badge.distance) {
                BadgeAnnotation *annotation = [BadgeAnnotation new];
                annotation.coordinate = thisLocCL.coordinate;
                annotation.title = badge.name;
                annotation.subtitle = badge.information;
                annotation.imageName = badge.imageName;
                [annotations addObject:annotation];
                break;
            }
        }
    }
    
    return annotations;
}

@end
