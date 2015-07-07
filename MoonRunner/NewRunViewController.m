//
//  NewRunViewController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "NewRunViewController.h"
#import "Run.h"

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController ()

@property (strong, nonatomic) Run *run;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@end

@implementation NewRunViewController
- (IBAction)startPressed:(id)sender {
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    self.stopButton.hidden = NO;
    self.distanceLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.paceLabel.hidden = NO;
}

- (IBAction)stopPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             
                                                         }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self performSegueWithIdentifier:detailSegueName sender:nil];
                                                       }];
    UIAlertAction *discardAction = [UIAlertAction actionWithTitle:@"Discard"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:saveAction];
    [alert addAction:discardAction];
    [self presentViewController:alert animated:TRUE completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.startButton.hidden = NO;
    self.promptLabel.hidden = NO;
    
    self.timeLabel.text = @"";
    self.distanceLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.stopButton.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
