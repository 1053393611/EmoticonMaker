//
//  PersonEmoticonViewController.h
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/18.
//  Copyright © 2016年 jin. All rights reserved.
//
//http://api.jiefu.tv/app2/api/dt/shareItem/getByTag.html?tagId=5&pageNum=0&pageSize=48
//http://api.jiefu.tv/app2/api/dt/shareItem/search.html?keyWord=j&pageNum=0&pageSize=48
#import "BaseViewController.h"

@interface PersonEmoticonViewController : BaseViewController
@property (nonatomic, copy) NSString *personname;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) bool isSearch;
-(instancetype)initWithName:(NSString *)name tagId:(NSInteger) tagId;
@end
