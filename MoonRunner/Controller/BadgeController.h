//
//  BadgeController.h
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const silverMultiplier;
extern float const goldMultiplier;

@class Badge;
@class Run;

@interface BadgeController : NSObject

+ (BadgeController *)defaultController;

- (NSArray *)earnStatusedForRuns:(NSArray *)runArray;

- (Badge *)bestBadgeForDistance:(float)distance;
- (Badge *)nextBadgeForDistance:(float)distance;

- (NSArray *)mapAnnotationsForRun:(Run *)run;

@end
