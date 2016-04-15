//
//  Location.m
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "Location.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "AugmentedReality.h"
#import "InterpolationMotionEffect.h"
#import "HomePage.h"
#import "MyProgressView.h"

#define IS_IPAD ([[UIDevice currentDevice].model isEqualToString:@"iPad"])

@interface Location () <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapType;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *navigateButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *carAnnotation;
@property (nonatomic) CLLocationCoordinate2D carLocation;

@property (copy, nonatomic) NSString *locationInfo;
@property (copy, nonatomic) NSString *dateInfo;

@property (strong, nonatomic) MyProgressView *indicator;
@property (strong, nonatomic) MKDirections *direction;
@property (strong, nonatomic) MKPolyline *overlay;

@property (strong, nonatomic) UIImage *image;

@property (nonatomic) BOOL ifFirstTime;

@end

@implementation Location

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ifFirstTime = YES;
    self.textField.layer.cornerRadius = 3.5;
    [InterpolationMotionEffect registerEffectForView:self.map depth:12];
    
    [self setupLocationManager];
    self.map.showsUserLocation = YES;
}

- (void)setupLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.delegate = self;
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.delegate = self;
                break;
            case kCLAuthorizationStatusNotDetermined:
                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.delegate = self;
                [_locationManager requestWhenInUseAuthorization];
            default:
                break;
        }
    } else {
        [self alertWithTitle:@"Not Enable" andMessage:@"Location services are not enabled in your device"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.map.showsUserLocation = YES;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self alertWithTitle:@"Location Authorization" andMessage:@"Please grant location service access (Settings -> Privacy -> Location)"];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.ifFirstTime) {
        self.carLocation = userLocation.coordinate;
        [self addCarAnnotation];
        [self performSelector:@selector(locateManually) withObject:nil afterDelay:1.5];
        self.ifFirstTime = NO;
    } else {
        [self showDistance];
    }
}

#pragma mark - Annotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
        annotationView.image = [UIImage imageNamed:@"Car.jpg"];
        annotationView.annotation = annotation;
        return annotationView;
    } else {
        return nil;
    }
}

- (MKPointAnnotation *)carAnnotation
{
    if (!_carAnnotation) {
        _carAnnotation = [[MKPointAnnotation alloc] init];
    }
    return _carAnnotation;
}

- (void)addCarAnnotation
{
    [self.map removeAnnotation:self.carAnnotation];
    
    self.carAnnotation.coordinate = self.carLocation;
    [self.map addAnnotation:self.carAnnotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
    MKCoordinateRegion regin = MKCoordinateRegionMake(self.carLocation, span);
    [self.map setRegion:regin animated:YES];
}

#pragma mark - TextField

- (void)takeNotesDown
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.carLocation.latitude longitude:self.carLocation.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            // Address
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *street = [placemark.addressDictionary valueForKey:@"Street"];
            NSString *city = [placemark.addressDictionary valueForKey:@"City"];
            NSString *state = [placemark.addressDictionary valueForKey:@"State"];
            NSString *zip = [placemark.addressDictionary valueForKey:@"ZIP"];
            self.locationInfo = [NSString stringWithFormat:@"%@, %@, %@ %@", street, city, state, zip];
            
            // Date
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            self.dateInfo = [dateFormatter stringFromDate:date];
            
            NSString *note = [NSString stringWithFormat:@"%@\n%@", self.locationInfo, self.dateInfo];
            self.textField.text = note;
            if (IS_IPAD) {
                self.textField.textAlignment = NSTextAlignmentCenter;
            } else {
                self.textField.textAlignment = NSTextAlignmentLeft;
            }
            
            self.carAnnotation.title = street;
            self.carAnnotation.subtitle = self.dateInfo;
            
        } else {
            NSLog(@"Decoding location ERROR!");
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AugmentedReality"]) {
        AugmentedReality *augmentedReality = (AugmentedReality *)segue.destinationViewController;
        augmentedReality.targetedLocation = self.carLocation;
        augmentedReality.parkedDate = self.dateInfo;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AugmentedReality"]) {
        BOOL takenNotes;
        if (self.dateInfo != nil) {
            takenNotes = YES;
        } else {
            takenNotes = NO;
        }
        return [self canUseCamera] && takenNotes;
    }
    return YES;
}

bool cameraAccessible;

- (BOOL)canUseCamera
{
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            return YES;
        case AVAuthorizationStatusDenied:
            [self alertWithTitle:@"Camera Authorization" andMessage:@"Please grant camera access (Settings -> Privacy -> Camera)"];
            return NO;
        case AVAuthorizationStatusRestricted:
            [self alertWithTitle:@"Can't Use Camera" andMessage:@"Sorry, the camera in your device is not accessible"];
            return NO;
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted == NO) {
                    [self alertWithTitle:@"Can't Use Camera" andMessage:@"Sorry, the camera in your device is not accessible"];
                    cameraAccessible = NO;
                } else {
                    cameraAccessible = YES;
                }
            }];
            return cameraAccessible;
    }
}

#pragma mark - Pathing

- (MyProgressView *)indicator
{
    if (!_indicator) {
        _indicator = [[MyProgressView alloc]initWithFrame:CGRectMake(0, 0, 120, 120) superView:self.view];
        [_indicator setMessage:@"Calculating Routes..."];
    }
    return _indicator;
}

- (IBAction)navigate:(UIButton *)sender {
    static NSUInteger typeTimes = 0;
    if (typeTimes % 3 == 0) {
        [self performSelectorOnMainThread:@selector(startTrackingUserWithHeading) withObject:nil waitUntilDone:NO];
        [self.navigateButton setBackgroundImage:[UIImage imageNamed:@"Navigate2"] forState:UIControlStateNormal];
    } else if (typeTimes % 3 == 1){
        if ([self.direction isCalculating] == NO) {
            [self.indicator show:NO];
            [self.direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                [self.indicator hide];
                if (error) {
                    [self alertWithTitle:@"Pathing Error" andMessage:@"Sorry, please try it again later."];
                } else {
                    [self drawRoutes:response.routes];
                    [self performSelectorOnMainThread:@selector(startTrackingUserWithHeading) withObject:nil waitUntilDone:NO];
                }
            }];
            [self.navigateButton setBackgroundImage:[UIImage imageNamed:@"Navigate1"] forState:UIControlStateNormal];

        }
    } else {
        [self.map removeOverlay:self.overlay];
        self.map.userTrackingMode = MKUserTrackingModeNone;
        [self.navigateButton setBackgroundImage:[UIImage imageNamed:@"Navigate"] forState:UIControlStateNormal];
    }
    
    [self setMapCamera];
    typeTimes++;
}

- (MKDirections *)direction
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.carLocation addressDictionary:nil]];
    
    _direction = [[MKDirections alloc] initWithRequest:request];
    return _direction;
}

- (void)drawRoutes:(NSArray *)routes
{
    for (int i = 0; i < [routes count]; i++) {
        if ([routes[i] isKindOfClass:[MKRoute class]]) {
            MKRoute *route = (MKRoute *)routes[i];
            [self.map addOverlay:route.polyline];
            self.overlay = route.polyline;
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [UIColor blueColor];
        polylineView.lineWidth = 6.0;
        return polylineView;
    }
    return nil;
}

#pragma mark - Distance

- (void)showDistance
{
    float distance = [self calculateDistance];
    if (distance > 15) {
        NSString *distanceString = [NSString stringWithFormat:@"Dist.  %.1fm", distance];
        self.distanceLabel.text = distanceString;
    } else {
        self.distanceLabel.text = @"Dist.  Near\t";
    }
}

#pragma mark - Park

- (IBAction)parkHere:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Park My Car Here" message:@"Parked at the new location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self locateManually];
        }
    } else if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Other Actions

- (IBAction)showMyself:(UIButton *)sender {
    static NSUInteger typeTimes = 0;
    self.map.userTrackingMode = MKUserTrackingModeNone;
    
    CLLocationCoordinate2D userLocation = self.map.userLocation.location.coordinate;
    CLLocationCoordinate2D carLocation = self.carLocation;
    
    if (typeTimes % 2 == 0) {
        [self.map setRegion:MKCoordinateRegionMake(userLocation, MKCoordinateSpanMake(0.02, 0.02))];
    } else {
        [self.map setRegion:MKCoordinateRegionMake(carLocation, MKCoordinateSpanMake(0.02, 0.02))];
    }
    
    [self setMapCamera];
    typeTimes++;
}

- (IBAction)goBack:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start a New Parking" message:@"Do you really wish to remove the parking info and start a new one?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = 200;
    [alert show];
}

- (IBAction)setMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.map setMapType:MKMapTypeStandard];
            [self setMapCamera];
            break;
        case 1:
            [self.map setMapType:MKMapTypeSatellite];
            break;
    }
}

#pragma mark - Other Trivial

- (void)setMapCamera
{
    self.map.camera.altitude = 200;
    self.map.camera.pitch = 60;
    self.map.showsBuildings = YES;
}

- (float)calculateDistance
{
    CLLocation *carLocation = [[CLLocation alloc] initWithLatitude:self.carLocation.latitude longitude:self.carLocation.longitude];
    CLLocation *userLocation = self.map.userLocation.location;
    float distance = [userLocation distanceFromLocation:carLocation];
    return distance;
}

- (void)locateManually
{
    self.carLocation = self.map.userLocation.coordinate;
    [self addCarAnnotation];
    [self takeNotesDown];
    [self showDistance];
    [self performSelector:@selector(setMapCamera) withObject:nil afterDelay:0.5];
}

- (void)startTrackingUserWithHeading
{
    self.map.userTrackingMode = MKUserTrackingModeFollowWithHeading;
}

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
