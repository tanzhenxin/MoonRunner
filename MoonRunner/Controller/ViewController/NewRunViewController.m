//
//  NewRunViewController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MathController.h"
#import "Location.h"
#import "NewRunViewController.h"
#import "BadgeController.h"
#import "Run.h"
#import "Location.h"
#import "Badge.h"
#import "WGS84TOGCJ02.h"

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) Run *run;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIImageView *nextBadgeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextBadgeLabel;

@property int seconds;
@property float distance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) Badge *upcomingBadge;

@end

@implementation NewRunViewController
- (IBAction)startPressed:(id)sender {
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    self.stopButton.hidden = NO;
    self.distanceLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.mapView.hidden = NO;
    self.mapView.delegate = self;
    self.nextBadgeLabel.hidden = NO;
    self.nextBadgeImageView.hidden = NO;
    
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                  target:self
                                                selector:@selector(eachSecond)
                                                userInfo:nil
                                                 repeats:true];
    [self startLocationUpdates];
    [self.mapView setShowsUserLocation:YES];
//    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:true];
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
                                                           [self saveRun];
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

- (void)eachSecond {
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDict:self.distance overTime:self.seconds]];
    
    self.nextBadgeLabel.text = [NSString stringWithFormat:@"%@ until %@!", [MathController stringifyDistance:(self.upcomingBadge.distance - self.distance)], self.upcomingBadge.name];
    [self checkNextBadge];
}

- (void)checkNextBadge {
    Badge *nextBadge = [[BadgeController defaultController] nextBadgeForDistance:self.distance];
    
    if (self.upcomingBadge && ![nextBadge.name isEqualToString:self.upcomingBadge.name]) {
        [self playSuccessSound];
    }
    
    self.upcomingBadge = nextBadge;
    self.nextBadgeImageView.image = [UIImage imageNamed:nextBadge.imageName];
}

- (void)playSuccessSound {
    NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/success.wav"];
    NSURL *filepath = [NSURL fileURLWithPath:path];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(filepath), &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 10;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)saveRun {
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                              inManagedObjectContext:self.managedObjectContext];
        newLocation.langitude = [NSNumber numberWithFloat:location.coordinate.longitude];
        newLocation.latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
        newLocation.timstamp = location.timestamp;
        [locationArray addObject:newLocation];
    }
   
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresloved error %@ %@", error, [error userInfo]);
        abort();
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setRun:self.run];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.startButton.hidden = NO;
    self.promptLabel.hidden = NO;
    
    self.timeLabel.text = @"";
    self.distanceLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.stopButton.hidden = YES;
    self.mapView.hidden = YES;
    self.nextBadgeImageView.hidden = YES;
    self.nextBadgeLabel.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        NSDate *timestamp = location.timestamp;
        NSTimeInterval interval = [timestamp timeIntervalSinceNow];
        
        if (fabs(interval) < 10.0 && location.horizontalAccuracy < 20) {
            
            // translate coordination if in China.
            CLLocation *newLocation;
            if (![WGS84TOGCJ02 isLocationOutOfChina:location.coordinate]) {
                newLocation = [[CLLocation alloc] initWithCoordinate:[WGS84TOGCJ02 transformFromWGSToGCJ:location.coordinate] altitude:location.altitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy timestamp:location.timestamp];
            } else {
                newLocation = location;
            }
            
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:mapRegion];
         
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
                [self.mapView addOverlay:polyline];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 3;
        return renderer;
    }
    
    return nil;
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
