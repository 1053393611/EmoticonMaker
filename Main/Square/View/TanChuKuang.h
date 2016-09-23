//
//  TanChuKuang.h
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/18.
//  Copyright © 2016年 jin. All rights reserved.
//

typedef void(^gaiziBolck)(EmoticonModel *model);

#import <UIKit/UIKit.h>

@interface TanChuKuang : UIView

@property (nonatomic ,strong) EmoticonModel *model;
@property (nonatomic, copy) gaiziBolck block;

-(void)show: (EmoticonModel *) model;

@end
