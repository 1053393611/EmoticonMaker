//
//  EmoticonModel.h
//  EmoticonMaker
//
//  Created by mac14 on 16/9/13.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmoticonModel : NSObject

@property(nonatomic, copy) NSString *gifPath;
@property(nonatomic, assign) NSInteger emoticonId;
@property(nonatomic, assign) NSInteger itemId;
@property(nonatomic, assign) NSInteger mediaType;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *picPath;

@end
