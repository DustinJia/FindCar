//
//  UIImage+Dustin.h
//  EasyParking
//
//  Created by Tomb on 14-9-12.
//  Copyright (c) 2014年 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Dustin)

// makes a copy at a different size
- (UIImage *)imageByScalingToSize:(CGSize)size;

// applies filter as described in Friday section
- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
