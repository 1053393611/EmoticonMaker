//
//  MineViewController.h
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/21.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "BaseViewController.h"

@interface MineViewController : BaseViewController
@property (nonatomic, copy) NSString *personname;
@property (nonatomic, strong) UICollectionView *collectionView;
-(instancetype)initWithName:(NSString *)name;
@end
