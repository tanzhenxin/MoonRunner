//
//  BadgeTableViewController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/8/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "BadgeTableViewController.h"
#import "Badge.h"
#import "BadgeCell.h"
#import "Run.h"
#import "BadgeEarnStatus.h"
#import "MathController.h"
#import "BadgeDetailViewController.h"

@interface BadgeTableViewController ()

@property (strong, nonatomic) UIColor *redColor;
@property (strong, nonatomic) UIColor *greenColor;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) CGAffineTransform transform;

@end

@implementation BadgeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.redColor = [UIColor colorWithRed:1.0f green:20/255.0 blue:44/255.0 alpha:1.0f];
    self.greenColor = [UIColor colorWithRed:0.0f green:146/255.0 blue:78/255.0 alpha:1.0f];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.transform = CGAffineTransformMakeRotation(M_PI/8);}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[BadgeDetailViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BadgeEarnStatus *earnStatus = [self.earnedStatusArray objectAtIndex:indexPath.row];
        ((BadgeDetailViewController *)[segue destinationViewController]).earnStatus = earnStatus;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.earnedStatusArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgeCell *cell = (BadgeCell *)[tableView dequeueReusableCellWithIdentifier:@"BadgeCell" forIndexPath:indexPath];
    
    BadgeEarnStatus *earnStatus = [self.earnedStatusArray objectAtIndex:indexPath.row];
    
    cell.silverImageView.hidden = !earnStatus.silverRun;
    cell.goldImageView.hidden = !earnStatus.goldRun;
    
    if (earnStatus.earnRun) {
        cell.nameLabel.textColor = self.greenColor;
        cell.nameLabel.text = earnStatus.badge.name;
        cell.earnedLabel.textColor = self.greenColor;
        cell.earnedLabel.text = [NSString stringWithFormat:@"Earned: %@", [self.dateFormatter stringFromDate:earnStatus.earnRun.timestamp]];
        cell.badgeImageView.image = [UIImage imageNamed:earnStatus.badge.imageName];
        cell.silverImageView.transform = self.transform;
        cell.goldImageView.transform = self.transform;
        cell.userInteractionEnabled = YES;
    } else {
        cell.nameLabel.textColor = self.redColor;
        cell.nameLabel.text = @"?????";
        cell.earnedLabel.textColor = self.redColor;
        cell.earnedLabel.text = [NSString stringWithFormat:@"Run %@ to Earn", [MathController stringifyDistance:earnStatus.badge.distance]];
        cell.badgeImageView.image = [UIImage imageNamed:@"question_badge.png"];
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
