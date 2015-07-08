//
//  BadgeCell.h
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *silverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goldImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *earnedLabel;

@end
