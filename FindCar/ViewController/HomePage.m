//
//  HomePage.m
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "HomePage.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>

@interface HomePage ()

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation HomePage
{
    SCNetworkReachabilityRef _reachabilityRef;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self canUseCamera];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Park"]) {
        if ([self checkInternetStatus] == NO) {
            [[[UIAlertView alloc] initWithTitle:@"Can't connect to Internet" message:@"Please open wifi or start using cellular data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return NO;
        }
    }
    return YES;
}

#pragma mark - Check Internet Status

- (BOOL)checkInternetStatus
{
    BOOL internetConnected = NO;
    BOOL wifiConnected = NO;
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    internetConnected = [self checkReachableWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    wifiConnected = [self checkReachableWithReachability:self.wifiReachability];
    
    return internetConnected || wifiConnected;
}

- (BOOL)checkReachableWithReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable:
            return NO;
        case ReachableViaWiFi:
            return YES;
        case ReachableViaWWAN:
            return YES;
    }
}

#pragma mark - Check Camera Authorization Status

- (void)canUseCamera
{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
    }
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
