//
//  UIImage+imageWithView.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/21.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "UIImage+imageWithView.h"

@implementation UIImage (imageWithView)



+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
