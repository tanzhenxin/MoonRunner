//
//  DetailViewController.m
//  MoonRunner
//
//  Created by 檀振兴 on 7/7/15.
//  Copyright (c) 2015 檀振兴. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "MultiColorPolylineSegment.h"
#import "BadgeController.h"
#import "Badge.h"
#import "BadgeAnnotation.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@end

@implementation DetailViewController
- (IBAction)infoButtonPressed:(id)sender {
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:badge.name
                              message:badge.information
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)toggleSpaceMode:(id)sender {
    UISwitch *switcher = (UISwitch *)sender;
    self.mapView.hidden = switcher.isOn;
    self.badgeImageView.hidden = !switcher.isOn;
    self.infoButton.hidden = !switcher.isOn;
}

#pragma mark - Managing the detail item

- (void)setRun:(Run *)run {
    if (_run != run) {
        _run = run;
        [self configureView];
    }
}

- (void)configureView {
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [dateFormatter stringFromDate:self.run.timestamp];
    
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];
    
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDict:self.run.distance.floatValue overTime:self.run.duration.intValue]];
    
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    self.badgeImageView.image = [UIImage imageNamed:badge.imageName];
    
    [self loadMap];
}

- (MKCoordinateRegion)mapRegion {
    MKCoordinateRegion region;
    Location *initLoc = self.run.locations.firstObject;
    
    float minLat = initLoc.latitude.floatValue;
    float minLog = initLoc.langitude.floatValue;
    float maxLat = initLoc.latitude.floatValue;
    float maxLog = initLoc.langitude.floatValue;
    
    for (Location *loc in self.run.locations) {
        if (loc.latitude.floatValue < minLat) {
            minLat = loc.latitude.floatValue;
        }
        if (loc.latitude.floatValue > maxLat) {
            maxLat = loc.latitude.floatValue;
        }
        if (loc.langitude.floatValue < minLog) {
            minLog = loc.langitude.floatValue;
        }
        if (loc.langitude.floatValue > maxLog) {
            maxLog = loc.langitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLog + maxLog) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f;
    region.span.longitudeDelta = (maxLog - minLog) * 1.1f;
    
    return region;
}

- (MKPolyline *)polyLine {
    CLLocationCoordinate2D coords[self.run.locations.count];
    
    for (int i = 0; i < self.run.locations.count; i++) {
        Location *location = [self.run.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.langitude.doubleValue);
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:self.run.locations.count];
}

- (void)loadMap
{
    if (self.run.locations.count > 0) {
        
        self.mapView.hidden = NO;
        self.mapView.delegate = self;
        
        // set the map bounds
        [self.mapView setRegion:[self mapRegion]];
        
        // make the line(s!) on the map
        NSArray *colorSegments = [MathController colorSegmentForLocations:self.run.locations.array];
        [self.mapView addOverlays:colorSegments];
        
        NSArray *annotations = [[BadgeController defaultController] mapAnnotationsForRun:self.run];
        [self.mapView addAnnotations:annotations];
        
    } else {
        
        // no locations were found!
        self.mapView.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Sorry, this run has no locations saved."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MultiColorPolylineSegment class]]) {
        MultiColorPolylineSegment *polyLine = (MultiColorPolylineSegment *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        renderer.strokeColor = polyLine.color;
        renderer.lineWidth = 3;
        return renderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    BadgeAnnotation *badgeAnnotation = (BadgeAnnotation *)annotation;
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"checkpoint"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:badgeAnnotation reuseIdentifier:@"checkPoint"];
        annotationView.image = [UIImage imageNamed:@"mapPin"];
        annotationView.canShowCallout = true;
    }
    
    UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 50)];
    badgeImageView.image = [UIImage imageNamed:badgeAnnotation.imageName];
    badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
    annotationView.leftCalloutAccessoryView = badgeImageView;
    
    return annotationView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.badgeImageView.hidden = YES;
    self.infoButton.hidden = YES;
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
