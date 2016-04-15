//
//  MyProgressView.m
//  TestIndicator
//
//  Created by Dustin on 15-2-1.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import "MyProgressView.h"

@implementation MyProgressView
@synthesize visible;

-(id)initWithFrame:(CGRect)frame superView:(UIView*)superView{
    
    rectOrigin = frame;
    rectSuper = [superView bounds];
    rectHud = CGRectMake(frame.origin.x,frame.origin.y, frame.size.width, frame.size.width);
    self = [super initWithFrame:rectHud];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        viewHud = [[UIView alloc]initWithFrame:rectHud];
        
        [self addSubview:viewHud];
        
        indicator = [[UIActivityIndicatorView alloc]
                   initWithActivityIndicatorStyle:
                   UIActivityIndicatorViewStyleWhiteLarge];
        
        double gridUnit = round(rectHud.size.width/12);
        float ind_width = 6*gridUnit;
        indicator.frame = CGRectMake(
                                   3*gridUnit,
                                   2*gridUnit,
                                   ind_width,
                                   ind_width);
        
        [viewHud addSubview:indicator];
        
        CGRect rectLabel = CGRectMake(1*gridUnit,
                                    9*gridUnit,
                                    10*gridUnit, 2*gridUnit);
        
        label = [[UILabel alloc]initWithFrame:rectLabel];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Arial" size:14];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.adjustsFontSizeToFitWidth = YES;
        
        [viewHud addSubview:label];
        visible = NO;
        
        [self setHidden:YES];
        [superView addSubview:self];
    }
    
    return self;
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    if(visible){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect boxRect = rectHud;
        
        // 绘制圆角矩形
        float radius = 10.0f;
    
        // 路径开始
        CGContextBeginPath(context);
        
        // 填充色：灰度0.0，透明度:0.1
        CGContextSetGrayFillColor(context,0.0f, 0.25);
        
        // 画笔移动到左上角的圆弧处
        CGContextMoveToPoint(context,CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
        
        // 开始绘制右上角圆弧：圆心x坐标，圆心y坐标，起始角，终止角，方向为顺时针
        CGContextAddArc(context,CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 33 * (float)M_PI / 2, 0, 0);
        
        // 开始绘制右下角圆弧
        CGContextAddArc(context,CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
        
        // 开始绘制左下角圆弧
        CGContextAddArc(context,CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
        
        // 开始绘制左上角圆弧
        CGContextAddArc(context,CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 33 * (float)M_PI / 2, 0);
        
        //        NSLog(@"MinX is:%f",CGRectGetMinX(boxRect));
        //        NSLog(@"MaxX is:%f",CGRectGetMaxX(boxRect));
        //        NSLog(@"MinY is:%f",CGRectGetMinY(boxRect));
        //        NSLog(@"MaxY is:%f",CGRectGetMaxY(boxRect));
        
        
        //  CGContextClosePath(context);// 关闭路径
        CGContextFillPath(context);// 填充路径,该函数自动关闭路径
        
        //将画面按照这个方向平移
        //[self setFrame:CGRectOffset(self.frame, 100, 160)];
        //这行代码是最新添加的，表示绘制结束后，讲画面放到屏幕最中间
        [self alignToCenter];
    }
}

#pragma mark Action

-(void)show:(BOOL)block{
    if (block && blocked==NO) {
        CGPoint offset = self.frame.origin;
        
        // 改变视图大小为父视图大小
        self.frame = rectSuper;
        viewHud.frame = CGRectOffset(viewHud.frame, offset.x, offset.y);
        
        if (maskView == nil) {
            maskView = [[UIView alloc]initWithFrame:rectSuper];
        } else{
            maskView.frame = rectSuper;
        }
        
        maskView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:maskView];
        [self bringSubviewToFront:maskView];
    
        blocked = YES;
    }
    
    [indicator startAnimating];
    [self setHidden:NO];
    [self setNeedsLayout];
    visible = YES;
}

#pragma mark 将这个东东隐藏

-(void)hide{
    visible = NO;
    [indicator stopAnimating];
    [self setHidden:YES];
}

#pragma mark 改变里面的文字

-(void)setMessage:(NSString*)newMsg{
    label.text=newMsg;
}

#pragma mark 将这个东东居中

-(void)alignToCenter{
    CGPoint centerSuper={rectSuper.size.width/2,rectSuper.size.height/2};
    CGPoint centerSelf={self.frame.origin.x+self.frame.size.width/2,
        self.frame.origin.y+self.frame.size.height/2};
    
    CGPoint offset={centerSuper.x-centerSelf.x,centerSuper.y-centerSelf.y};
    CGRect newRect=CGRectOffset(self.frame, offset.x, offset.y);
    
    [self setFrame:newRect];
    rectHud=newRect;
}

@end