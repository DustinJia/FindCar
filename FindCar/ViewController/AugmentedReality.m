//
//  AugmentedReality.m
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "AugmentedReality.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "InterpolationMotionEffect.h"
#import "ShutDown.h"
#import "UIImage+Dustin.h"

#define IS_IPAD ([[UIDevice currentDevice].model isEqualToString:@"iPad"])

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

@interface AugmentedReality () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;

@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) UIImageView *carImageView;
@property (strong, nonatomic) UITextView *infoTextView;
@property (strong, nonatomic) UIImageView *messageView;

@end

@implementation AugmentedReality
{
    CLLocationDegrees latitudeOfTargetedPoint;
    CLLocationDegrees longitudeOfTargetedPoint;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"Arrow.png"];
        CGPoint center = self.view.center;
        
        if (IS_IPAD) {
            _arrowImageView.frame = CGRectMake(center.x-75, center.y+20, 150, 150);
        } else {
            _arrowImageView.frame = CGRectMake(center.x-50, center.y+30, 100, 100);
        }
        
        _arrowImageView.alpha = 0.8;
        [InterpolationMotionEffect registerEffectForView:_arrowImageView depth:20];
    }
    return _arrowImageView;
}

- (UIImageView *)carImageView
{
    if (!_carImageView) {
        _carImageView = [[UIImageView alloc] init];
        _carImageView.image = [UIImage imageNamed:@"Car"];
        CGPoint center = self.view.center;
        
        if (IS_IPAD) {
            _carImageView.frame = CGRectMake(center.x-45, center.y-180, 90, 90);
        } else {
            _carImageView.frame = CGRectMake(center.x-30, center.y-110, 60, 60);
        }
    }
    return _carImageView;
}

- (UITextView *)infoTextView
{
    if (!_infoTextView) {
        _infoTextView = [[UITextView alloc] init];
        CGPoint center = self.view.center;
        if (IS_IPAD) {
            _infoTextView.frame = CGRectMake(center.x-225, center.y-220, 450, 225);
        } else {
            _infoTextView.frame = CGRectMake(center.x-150, center.y-150, 300, 150);
        }
        _infoTextView.backgroundColor = [UIColor clearColor];
        _infoTextView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22];
        UIColor *orchid = [AugmentedReality colorWithHex:0x00F5FF alpha:1.0];
        _infoTextView.textColor = orchid;
        _infoTextView.textAlignment = NSTextAlignmentCenter;
    }
    return _infoTextView;
}

- (UIImageView *)messageView
{
    if (!_messageView) {
        _messageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Message"]];
        _messageView.center = self.view.center;
        [_messageView sizeToFit];
        
        UITextView *textView = [[UITextView alloc] init];
        textView.bounds = _messageView.bounds;
        
        textView.center = CGPointMake(_messageView.bounds.size.width/2, _messageView.bounds.size.height/2);
        textView.backgroundColor = [UIColor clearColor];
        NSString *text = [NSString stringWithFormat:@"\nYour car is very near to you.\nSaved on %@", self.parkedDate];
        textView.text = text;
        
        if (IS_IPAD) {
            textView.font = [UIFont fontWithName:@"Palatino" size:18];
        } else {
            textView.font = [UIFont fontWithName:@"Palatino" size:19];
        }
        textView.textColor = [UIColor whiteColor];
        textView.textAlignment = NSTextAlignmentCenter;
        
        [_messageView addSubview:textView];
        if (IS_IPAD) {
            [InterpolationMotionEffect registerEffectForView:_messageView depth:60];
        } else {
            [InterpolationMotionEffect registerEffectForView:_messageView depth:15];
        }
    }
    return _messageView;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAVWindow];
    [self configureShutDownAnimation];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    [self.view addSubview:self.arrowImageView];
    [self.view addSubview:self.carImageView];
    [self.view addSubview:self.infoTextView];
    [self.view addSubview:self.messageView];
    
    self.arrowImageView.hidden = YES;
    self.carImageView.hidden = YES;
    self.infoTextView.hidden = YES;
    self.messageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - AVCaptureDevice

- (void)setupAVWindow
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];

    if (IS_IPAD) {
        captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    } else {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    CGSize size = self.view.bounds.size;
    captureVideoPreviewLayer.frame = CGRectMake(CGRectGetMinX(self.view.bounds),CGRectGetMinY(self.view.bounds), size.width, size.height);
    [self.view.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    if (deviceInput) {
        [captureSession addInput:deviceInput];
        [captureSession startRunning];
    }
}

#pragma mark - Animation

- (float)calculateAngle
{
    float userLocationLatitude = DegreesToRadians(self.userLocation.coordinate.latitude);
    float userLocationLongitude = DegreesToRadians(self.userLocation.coordinate.longitude);
    
    float targetedPointLatitude = DegreesToRadians(self.targetedLocation.latitude);
    float targetedPointLongitude = DegreesToRadians(self.targetedLocation.longitude);
    
    float longitudeDifference = targetedPointLongitude - userLocationLongitude;
    
    float y = sin(longitudeDifference) * cos(targetedPointLatitude);
    float x = cos(userLocationLatitude) * sin(targetedPointLatitude) - sin(userLocationLatitude) * cos(targetedPointLatitude) * cos(longitudeDifference);
    float radiansValue = atan2(y, x);
    if(radiansValue < 0.0) {
        radiansValue += 2*M_PI;
    }
    
    return radiansValue;
}

- (float)calculateDistance
{
    CLLocation *targetedLoacation = [[CLLocation alloc] initWithLatitude:self.targetedLocation.latitude longitude:self.targetedLocation.longitude];
    float distance = [self.userLocation distanceFromLocation:targetedLoacation];
    
    return distance;
}

- (void)rotateArrowWithAngle:(float)angle
{
    [UIView animateWithDuration:0.1 animations:^{
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
    }];
}

- (void)moveCarImageWithAngle:(float)angle andVerticalDistanceFromArrow:(float)distance
{
    float x = tanf(angle) * distance;
    
    if ((angle >= -1.5  && angle <= 1.5) || (angle >= 5.0 && angle <= 7.5)) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.carImageView.transform = CGAffineTransformMakeTranslation(x, 0);
                             self.infoTextView.transform = CGAffineTransformMakeTranslation(x, 0);
                         }
                         completion:^(BOOL finished) {
                             self.infoTextView.hidden = NO;
                             self.carImageView.hidden = NO;
                         }];
    }
}


#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userLocation = self.locationManager.location;
    float distance = [self calculateDistance];
    NSString *distanceString = [NSString stringWithFormat:@"%.f meters / %.1f miles",distance, distance/1609];
    self.infoTextView.text = distanceString;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    float direction = newHeading.magneticHeading;
    
    if (direction > 180) {
        direction = 360 - direction;
    } else {
        direction = 0 - direction;
    }
    
    float angle = [self calculateAngle]+DegreesToRadians(direction);
    [self rotateArrowWithAngle:angle];
    
    float distance = [self calculateDistance];
    if (distance > 15) {
        self.arrowImageView.hidden = NO;
        self.messageView.hidden = YES;
        [self moveCarImageWithAngle:angle andVerticalDistanceFromArrow:150];
    } else {
        self.infoTextView.hidden = YES;
        self.carImageView.hidden = YES;
        self.arrowImageView.hidden = YES;
        self.messageView.hidden = NO;
    }
}

#pragma mark - ShutDown

- (void)configureShutDownAnimation
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.view addGestureRecognizer:tap];
}

- (void)close
{
    UIView *blackView, *whiteView;
    CGRect screen = [UIScreen mainScreen].bounds;
    blackView = [[UIView alloc]initWithFrame:screen];
    blackView.backgroundColor = [UIColor blackColor];
    whiteView = [[UIView alloc]initWithFrame:screen];
    whiteView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:blackView];
    [blackView addSubview:whiteView];
    
    [AugmentedReality beginExitAnimation:whiteView blackView:blackView];
    [self performSelector:@selector(goBack) withObject:nil afterDelay:0.6];
}

+(void)animateOut:(UIView *)theView bView:(UIView*)bview
{
    [UIView animateWithDuration:0.5 animations:^{
        theView.transform = CGAffineTransformMakeScale(1, 0.005);
    } completion:^(BOOL finished){
        ShutDown *view = [[ShutDown alloc]initWithFrame:[UIScreen mainScreen].bounds];
        view.center = bview.center;
        
        [bview addSubview:view];
        
        [UIView animateWithDuration:0.31 animations:^{
            theView.transform = CGAffineTransformMakeScale(0, 0);
            view.transform = CGAffineTransformMakeScale(1, 0.0000001);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [theView removeFromSuperview];
            });
        }];
    }];
}

+ (void)beginExitAnimation:(UIView *)view blackView:(UIView*)bView
{
    [AugmentedReality animateOut:view bView:bView];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end