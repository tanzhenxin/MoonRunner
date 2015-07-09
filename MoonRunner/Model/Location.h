//
//  Location.h
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Run;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * langitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timstamp;
@property (nonatomic, retain) Run *run;

@end
