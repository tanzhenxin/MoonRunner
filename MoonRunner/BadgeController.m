//
//  BadgeController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "BadgeController.h"
#import "Badge.h"

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
    badge.description = [dict objectForKey:@"discription"];
    return badge;
}

@end
