//
//  EmoticonModel.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/13.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "EmoticonModel.h"

@implementation EmoticonModel


+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"emoticonId" : @"id"
             };
}

@end
