//
//  AugmentedReality.h
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AugmentedReality : UIViewController

@property (nonatomic) CLLocationCoordinate2D targetedLocation;
@property (copy, nonatomic) NSString *parkedDate;

@end
