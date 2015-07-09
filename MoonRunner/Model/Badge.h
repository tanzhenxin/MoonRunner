//
//  Badge.h
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Badge : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *information;
@property float distance;

@end
