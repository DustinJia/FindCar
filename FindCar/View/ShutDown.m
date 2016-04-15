//
//  ShutDown.m
//  CarFinder
//
//  Created by Dustin on 15-2-10.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "ShutDown.h"

@implementation ShutDown

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    float offset = 1.5;
    float my = rect.size.height/2.0;
    float mx = rect.size.width/2.0;
    UIBezierPath* aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mx-2*offset, my-offset, 4*offset, 2*offset)];
    [aPath moveToPoint:CGPointMake(0, my)];
    [aPath addLineToPoint:CGPointMake(mx, my-offset)];
    [aPath addLineToPoint:CGPointMake(2*mx, my)];
    [aPath addLineToPoint:CGPointMake(mx, my+offset)];
    [aPath closePath];
    // Set the render colors
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    [aPath fill];
}

@end