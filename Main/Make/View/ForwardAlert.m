//
//  ForwardAlert.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/20.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "ForwardAlert.h"

#define kAlertViewWidth (kScreenWidth - 60)
#define kAlertViewHeight (kScreenHeight - 200)

@interface ForwardAlert()

@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UIView *controlView;

@end


@implementation ForwardAlert


- (instancetype)init{
    
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if(self){
        
        self.hidden = NO;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.controlView];
        [self addSubview:self.alertView];
    }
    return self;
    
}

#pragma mark - 灰色白透明视图
- (UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _controlView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenView:)];
        [_controlView addGestureRecognizer:tap];
    }
    return _controlView;
}


- (void)hiddenView:(UITapGestureRecognizer *)tap
{
    self.hidden = YES;
}


#pragma mark - 内容视图
- (UIView *)alertView{
    if(!_alertView){
        _alertView = [[UIView alloc]initWithFrame:CGRectMake(30, 100, kAlertViewWidth, kAlertViewHeight)];

        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.cornerRadius = 4;
        _alertView.layer.masksToBounds = YES;
        
        UILabel *fsTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 12, kAlertViewWidth, 25)];
        fsTitleLabel.text = @"发送表情到";
        fsTitleLabel.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:fsTitleLabel];
        
        
        _gifImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 50, kAlertViewWidth - 60, kAlertViewWidth - 60)];
        
        
        _gifImageView.layer.cornerRadius = 5;
        _gifImageView.layer.masksToBounds = YES;
        _gifImageView.layer.borderColor = [UIColor grayColor].CGColor;
        _gifImageView.layer.borderWidth = 1;
        [_alertView addSubview:_gifImageView];
        
        
        NSArray *bArray = @[@"fasongweixin", @"fasongqq", @"fasongbendi"];
        float width = kAlertViewWidth / 3;
        for (int i = 0; i < 3; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width * i, kAlertViewWidth - 30, width, width * 1.4)];
            [button setImage:[UIImage imageNamed:bArray[i]] forState:UIControlStateNormal];
            
            button.tag = i + 100;
            
            [_alertView addSubview:button];
            
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kAlertViewWidth - 50 + width * 1.4, kAlertViewWidth, 50)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"menubg"] forState:UIControlStateNormal];
        cancelButton.tag = 103;
        
        [_alertView addSubview:cancelButton];
        
        [cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

        
        _alertView.frame = CGRectMake(0, 0, kAlertViewWidth, kAlertViewWidth + width *1.4);
        _alertView.center = self.center;
        
        
    }
    return _alertView;
}

- (void)buttonAction:(UIButton *)button {
    switch (button.tag - 100) {
        case 0:
        {
           
            break;
        }
        case 1:
        {
            
            break;
        }
        case 2:
        {
            //下载
            [self downLoad];
            self.hidden = YES;
            break;
        }
        case 3:
        {
            self.hidden = YES;
            break;
        }
        default:
            break;
    }
}

#pragma mark - 保存
- (void)downLoad {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *homePath = NSHomeDirectory();
    
    NSString *scImagePath = [homePath stringByAppendingPathComponent:@"Documents/baocun"];
    
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
        data = UIImageJPEGRepresentation(_gifImageView.animationImages[0], 1);
        
        // 暂未解决将图片数组转成gif图片，暂时只保存图片数组的第一张图片
        
        //        NSMutableData *mdata = [NSMutableData data];
        //
        //        for (UIImage *image in _gifImageView.animationImages) {
        //            [mdata appendData:UIImageJPEGRepresentation(image, 1)];
        //           // NSLog(@"%@", mdata);
        //        }
        //
        //        data = [mdata copy];
    }else {
        imgPath = [scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.png",_model.emoticonId]];
        data = UIImageJPEGRepresentation(_gifImageView.image, 1);
    }
    
    //NSLog(@"%@", imgPath);
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
        
        hud.labelText = @"保存成功";
        
    }else {
        hud.labelText = @"已保存,不需要重复";
    }
    
    
}


@end
