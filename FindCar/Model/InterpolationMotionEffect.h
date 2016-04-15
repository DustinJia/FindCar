//
//  InterpolationMotionEffect.h
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InterpolationMotionEffect : NSObject

+ (void)registerEffectForView:(UIView *)aView depth:(CGFloat)depth;

@end
