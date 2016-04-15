//
//  UIImage+Dustin.m
//  EasyParking
//
//  Created by Tomb on 14-9-12.
//  Copyright (c) 2014年 Dustin. All rights reserved.
//

#import "UIImage+Dustin.h"

@implementation UIImage (Dustin)

- (UIImage *)imageByScalingToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName
{
    UIImage *filteredImage = self;
    
    //Step 1: create CIImage object
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        //Step 2: get the filter
        CIFilter *filter = [CIFilter filterWithName:filterName];
        //Step 3: provide arguments
        [filter setValue:inputImage forKey:kCIInputImageKey];
        //Step 4: get output image
        CIImage *outputImage = [filter outputImage];
        if (outputImage) {
            filteredImage = [UIImage imageWithCIImage:outputImage];
            if (filteredImage) {
                //Step 5: draw it into a new image
                UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
                [filteredImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
                filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }
    
    return filteredImage;
}

@end
