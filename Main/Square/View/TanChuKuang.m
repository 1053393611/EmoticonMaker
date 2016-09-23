//
//  TanChuKuang.m
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/18.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "TanChuKuang.h"
#import "MakeViewController.h"
#import "BaseNavigationController.h"

@interface TanChuKuang()
{
    UIImageView *imageView;
    UIView *smallView;
    UIView *huiview;
}

@end

@implementation TanChuKuang

-(instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight)];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)yingcang {
    self.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        smallView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 160);
        huiview.frame = CGRectMake(0, 0, kScreenWidth,kScreenHeight);
    }];
}

-(void)show: (EmoticonModel *) model{
    _model = model;
    self.hidden = NO;
    if (model.mediaType == 1) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.gifPath]];
    }else {
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.picPath]];
    }
    [UIView animateWithDuration:0.25 animations:^{
        smallView.frame = CGRectMake(0, kScreenHeight - 160, kScreenWidth, 160);
        huiview.frame = CGRectMake(0, 0, kScreenWidth,kScreenHeight - 160);
    }];
}

-(void)createUI {
    
    huiview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight)];
    huiview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self addSubview:huiview];
    UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yingcang)];
    [huiview addGestureRecognizer:tapges];
    
    smallView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 160)];
    
    [self addSubview:smallView];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 20, 120, 120)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    [smallView addSubview:imageView];
    smallView.backgroundColor = [UIColor colorWithRed:210.0 / 255.0 green:1.0 blue:209.0 / 255.0 alpha:1.0];
    NSArray *array = @[@"faweixin",@"faqq",@"gaizi",@"shoucang"];
    
    CGFloat btnwidth = (kScreenWidth - 30 - 120 - 15 - 25 - 30) / 2.0;
    CGFloat btnheight = (120 - 10 - 20) / 2.0;
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(30 + 120 + 10 +(25 + btnwidth) * j , 40 + (btnheight + 10) * i, btnwidth, btnheight)];
            button.tag = i * 2 + j;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageNamed:array[i * 2 + j]] forState:UIControlStateNormal];
            [smallView addSubview:button];
        }
        
    }
}

- (void)buttonAction:(UIButton *)button {
    switch (button.tag) {
        case 0:
            NSLog(@"微信");
            break;
        case 1:
            NSLog(@"QQ");
            break;
        case 2:
            //NSLog(@"改字");
            [self gaizi];
            break;
        case 3:
            //NSLog(@"收藏");
            [self shoucang];
            break;
        default:
            break;
    }
}
#pragma mark - 收藏
- (void)shoucang {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    NSString *scImagePath = [homePath stringByAppendingPathComponent:@"Documents/shoucang"];
    
    if (![manager fileExistsAtPath:scImagePath]) {
        [manager createDirectoryAtPath:scImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
   
    NSString *dataPath = [scImagePath stringByAppendingPathComponent:@"dataArray"];
    NSDictionary *dic = @{[NSString stringWithFormat:@"%li",_model.emoticonId]:[NSNumber numberWithInteger:_model.mediaType]};
    if (![manager fileExistsAtPath:dataPath]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [data writeToFile:dataPath atomically:YES];
    }else {
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        BOOL b = YES;
        for (NSString *key in [dic allKeys]) {
            if ([key isEqualToString:[NSString stringWithFormat:@"%li",_model.emoticonId]]) {
                b = NO;
            }
        }
        if (b == YES) {
            [dic setObject:[NSNumber numberWithInteger:_model.mediaType] forKey:[NSString stringWithFormat:@"%li",_model.emoticonId]];
            NSData *d = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [d writeToFile:dataPath atomically:YES];
        }
    }
    
    NSData *data;
    NSString *imgPath;
    if (_model.mediaType == 1) {
        imgPath = [scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.gif",_model.emoticonId]];
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_model.gifPath]];
    }else {
        imgPath = [scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.png",_model.emoticonId]];
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_model.picPath]];
    }
    
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    hud.mode = MBProgressHUDModeText;
    
    hud.margin = 10.f;
    hud.cornerRadius = 20;
    hud.yOffset = kScreenHeight / 3;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    if (![manager fileExistsAtPath:imgPath]) {
        [data writeToFile:imgPath atomically:YES];
        
        hud.labelText = @"收藏成功";
        
    }else {
        hud.labelText = @"已收藏,不需要重复";
    }
    
    
    [self yingcang];
    
}
#pragma mark - 改字
-(void)gaizi {
    
    
//
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"tiaozhuan" object:nil];
    
    if (_block != nil) {
        _block(_model);
    }
    [self yingcang];
}
@end
