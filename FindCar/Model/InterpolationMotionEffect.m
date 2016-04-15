//
//  InterpolationMotionEffect.m
//  CarFinder
//
//  Created by Dustin on 15-1-28.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "InterpolationMotionEffect.h"

@implementation InterpolationMotionEffect

+ (void)registerEffectForView:(UIView *)aView depth:(CGFloat)depth
{
    UIInterpolatingMotionEffect *effectX;
    UIInterpolatingMotionEffect *effectY;
    effectX = [[UIInterpolatingMotionEffect alloc]
               initWithKeyPath:@"center.x"
               type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectY = [[UIInterpolatingMotionEffect alloc]
               initWithKeyPath:@"center.y"
               type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    effectX.maximumRelativeValue = @(depth);
    effectX.minimumRelativeValue = @(-depth);
    effectY.maximumRelativeValue = @(depth);
    effectY.minimumRelativeValue = @(-depth);
    
    [aView addMotionEffect:effectX];
    [aView addMotionEffect:effectY];
}

@end
