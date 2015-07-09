//
//  BadgeDetailViewController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/9/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "BadgeDetailViewController.h"
#import "BadgeEarnStatus.h"
#import "Badge.h"
#import "Run.h"
#import "MathController.h"
#import "BadgeController.h"

@interface BadgeDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeInfoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *earnedLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestLabel;
@property (weak, nonatomic) IBOutlet UILabel *silverLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *silverBadgeView;
@property (weak, nonatomic) IBOutlet UIImageView *goldBadgeView;

@end

@implementation BadgeDetailViewController
- (IBAction)infoButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:self.earnStatus.badge.name
                              message:self.earnStatus.badge.information
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/8);
    
    self.nameLabel.text = self.earnStatus.badge.name;
    self.distanceLabel.text = [MathController stringifyDistance:self.earnStatus.badge.distance];
    self.badgeImageView.image = [UIImage imageNamed:self.earnStatus.badge.imageName];
    self.earnedLabel.text = [NSString stringWithFormat:@"Reached on %@" , [formatter stringFromDate:self.earnStatus.earnRun.timestamp]];
    
    if (self.earnStatus.silverRun) {
        self.silverBadgeView.transform = transform;
        self.silverBadgeView.hidden = NO;
        self.silverLabel.text = [NSString stringWithFormat:@"Earned on %@" , [formatter stringFromDate:self.earnStatus.silverRun.timestamp]];
        
    } else {
        self.silverBadgeView.hidden = YES;
        self.silverLabel.text = [NSString stringWithFormat:@"Pace < %@ for silver!", [MathController stringifyAvgPaceFromDict:(self.earnStatus.earnRun.distance.floatValue * silverMultiplier) overTime:self.earnStatus.earnRun.duration.intValue]];
    }
    
    if (self.earnStatus.goldRun) {
        self.goldBadgeView.transform = transform;
        self.goldBadgeView.hidden = NO;
        self.goldLabel.text = [NSString stringWithFormat:@"Earned on %@" , [formatter stringFromDate:self.earnStatus.goldRun.timestamp]];
        
    } else {
        self.goldBadgeView.hidden = YES;
        self.goldLabel.text = [NSString stringWithFormat:@"Pace < %@ for gold!", [MathController stringifyAvgPaceFromDict:(self.earnStatus.earnRun.distance.floatValue * goldMultiplier) overTime:self.earnStatus.earnRun.duration.intValue]];
    }
    
    self.bestLabel.text = [NSString stringWithFormat:@"Best: %@, %@", [MathController stringifyAvgPaceFromDict:self.earnStatus.bestRun.distance.floatValue overTime:self.earnStatus.bestRun.duration.intValue], [formatter stringFromDate:self.earnStatus.bestRun.timestamp]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
