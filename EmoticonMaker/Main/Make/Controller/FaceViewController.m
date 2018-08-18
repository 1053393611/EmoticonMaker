//
//  FaceViewController.m
//  EmoticonMaker
//
//  Created by mac on 2017/5/16.
//  Copyright © 2017年 mac14. All rights reserved.
//

#import "FaceViewController.h"
#import "EmoticonCell.h"
#import "UIView+ColorOfPoint.h"
#import "ForwardAlert.h"
#import "UIImage+imageWithView.h"
#import <ImageIO/ImageIO.h>

@interface FaceViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
{
    NSMutableDictionary *_dataDic;
    BOOL _isLoadData;
    
    UIImageView *_imageView;
    UITextView *_textView;
    UIImageView *_toolView;
    UITableView *_tableView;
    UIScrollView *_wenziScrollView;
    UIScrollView *_beijingScrollView;
    UIScrollView *_zitiScrollView;
    UIImageView *_quseImageView;
    UIImageView *_quseImgView;
    UIImageView *_faceView;
    
    NSArray *_BGArray;
    NSMutableArray *_imageArray;
    CGFloat _delayTime;
    CGPoint _textViewCenter;
    CGPoint _beginPoint;
    CGPoint _beginCenter;
    
    CGAffineTransform _transform;
    CGAffineTransform _transformTwo;
    
}


@end

@implementation FaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _BGArray = @[@"我已经帅的不能自理",
                 @"我再也不和你玩了",
                 @"你做我媳妇会死啊",
                 @"为什么没人理我，是因为我长得帅吗？",
                 @"康忙北鼻来此购",
                 @"你们真是年轻不懂事",
                 @"我去装逼了，你们照顾好自己",
                 @"走吧，你显然不是我的对手",
                 @"我不喜欢和人说废话",
                 @"给你一次做我儿子的机会"];
    
    self.title = @"制作表情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _dataDic = [[NSMutableDictionary alloc] init];
    
    _isLoadData = NO;
    
    [self createUI];
    
    [self loadData];
    
    
    
    
}

#pragma mark - 创建UI
- (void)createUI {
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    _imageView.image = [UIImage imageNamed:@"loading"];
    _imageView.userInteractionEnabled = YES;
    
    [self.view addSubview:_imageView];
    
    
    _faceView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 150, 150)];
    _faceView.userInteractionEnabled = YES;
    _faceView.image = [UIImage imageNamed:@"loading"];
    _faceView.layer.cornerRadius = 50;
    _faceView.layer.masksToBounds = YES;
    [_imageView addSubview:_faceView];
    
    /* step1: 声明和初始化一个手势识别器 */
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    rotation.delegate = self;
    pinch.delegate = self;
    
    /* step3：把手势识别器加到view中去 */
    [_imageView addGestureRecognizer:rotation];
    [_imageView addGestureRecognizer:pan];
    [_imageView addGestureRecognizer:pinch];
    
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 40, 100)];
    _textViewCenter = CGPointMake(kScreenWidth / 2, kScreenWidth - 55);
    _textView.center = _textViewCenter;
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.delegate = self;
    _textView.font = [UIFont fontWithName:@"ArialMT" size:35];;
    _textView.layer.shadowOpacity = 1;
    _textView.layer.shadowRadius = 3;
    _textView.layer.shadowColor = [UIColor whiteColor].CGColor;
    _textView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
    _textView.backgroundColor = [UIColor clearColor];
    _textView.scrollEnabled = NO;
    [_imageView addSubview:_textView];
    
    
    [self createToolView];
    
    [self createBottomView];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = right;
}

- (void)sendAction:(UIButton *)button {
    EmoticonModel *model = _dataDic[@"item"];
    ForwardAlert *alertView = [[ForwardAlert alloc] init];
    alertView.model = model;
    alertView.viewCtr = self;
    UIImage *image;
    if (model.mediaType == 0) {
        image = [UIImage imageWithView:_imageView];
        alertView.gifImageView.image = image;
    } else {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.gifPath]];
        [self decodeWithData:data];
        alertView.gifImageView.animationImages = _imageArray;
        alertView.gifImageView.animationDuration = _delayTime;
        alertView.gifImageView.animationRepeatCount = 0;
        [alertView.gifImageView startAnimating];
    }
    
    
    [self.view.window addSubview:alertView];
}

#pragma mark - 手势

/* 识别拖动 */
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    _faceView.center = location;
    [_textView resignFirstResponder];
    
}

/* 识别翻转 */
- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer {
    
    CGAffineTransform transform = CGAffineTransformMakeRotation([gestureRecognizer rotation]);
    
    
    _faceView.transform = CGAffineTransformRotate(gestureRecognizer.view.transform, [gestureRecognizer rotation]);
    
    _transform = _faceView.transform;
    
    _faceView.transform =CGAffineTransformConcat(_transformTwo, transform);
    
}


/* 识别放大缩小 */
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    CGAffineTransform transform = CGAffineTransformMakeScale(gestureRecognizer.scale, gestureRecognizer.scale);
    
    _faceView.transform = CGAffineTransformScale(gestureRecognizer.view.transform, gestureRecognizer.scale, gestureRecognizer.scale);
    
    
    _transformTwo = _faceView.transform;
    _faceView.transform =CGAffineTransformConcat(_transform, transform);
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - 解析gif
-(void)decodeWithData:(NSData *)data
{
    _imageArray = [NSMutableArray array];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef) data, NULL);
    if (src)
    {
        //获取gif的帧数
        NSUInteger frameCount = CGImageSourceGetCount(src);
        //获取GfiImage的基本数据
        NSDictionary *gifProperties = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyProperties(src, NULL));
        if(gifProperties)
        {
            
            for (NSUInteger i = 0; i < frameCount; i++)
            {
                //得到每一帧的CGImage
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, (size_t) i, NULL);
                if (img)
                {
                    //把CGImage转化为UIImage
                    UIImage *frameImage = [UIImage imageWithCGImage:img];
                    _imageView.image = frameImage;
                    UIImage *image = [UIImage imageWithView:_imageView];
                    [_imageArray addObject:image];
                    
                    
                    //获取每一帧的图片信息
                    NSDictionary *frameProperties = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, (size_t) i, NULL));
                    if (frameProperties)
                    {
                        //由每一帧的图片信息获取gif信息
                        NSDictionary *frameDictionary = [frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
                        //取出每一帧的delaytime
                        CGFloat delayTime = [[frameDictionary objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
                        
                        _delayTime = delayTime * frameCount;
                        
                    }
                }
                EmoticonModel *model = _dataDic[@"item"];
                [_imageView sd_setImageWithURL:[NSURL URLWithString:model.gifPath]];
            }
            
        }
        
    }
}




#pragma mark - createToolView

-(void)createToolView {
    
    _toolView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenWidth, kScreenWidth, 70)];
    _toolView.userInteractionEnabled = YES;
    [self createButton];
    _toolView.image = [UIImage imageNamed:@"gongjubg"];
    
    [self.view addSubview:_toolView];
    
}

- (void)createButton {
    
    
    NSArray *array = @[@"peiwen", @"wenzise", @"beijingse", @"ziti"];
    NSArray *sArray = @[@"peiwenlv", @"wenziselv", @"beijingselv", @"zitilv"];
    float width = kScreenWidth / 4;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width * i, 0, width, 70)];
        [button setImage:[UIImage imageNamed:array[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:sArray[i]] forState:UIControlStateSelected];
        button.tag = i + 100;
        
        if (i == 0) {
            button.selected = YES;
        }
        
        [_toolView addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)buttonAction:(UIButton *)button {
    button.selected = YES;
    for (int i = 0; i < 4; i++) {
        UIButton *b = [_toolView viewWithTag:i+100];
        if (b.tag != button.tag) {
            b.selected = NO;
        }
    }
    switch (button.tag - 100) {
        case 0:
        {
            _tableView.hidden = NO;
            _wenziScrollView.hidden = YES;
            _beijingScrollView.hidden = YES;
            _zitiScrollView.hidden = YES;
            
            break;
        }
        case 1:
        {
            _tableView.hidden = YES;
            _wenziScrollView.hidden = NO;
            _beijingScrollView.hidden = YES;
            _zitiScrollView.hidden = YES;
            
            break;
        }
        case 2:
        {
            _tableView.hidden = YES;
            _wenziScrollView.hidden = YES;
            _beijingScrollView.hidden = NO;
            _zitiScrollView.hidden = YES;
            
            break;
        }
        case 3:
        {
            _tableView.hidden = YES;
            _wenziScrollView.hidden = YES;
            _beijingScrollView.hidden = YES;
            _zitiScrollView.hidden = NO;
            
            break;
        }
        default:
            break;
    }
}


#pragma mark createBottomView

- (void)createBottomView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kScreenWidth + 70, kScreenWidth , kScreenHeight - kScreenWidth - 70 - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
    
    [self createWenziScrollView];
    
    [self createBeijingScrollView];
    
    [self createZitiScrollView];
    
}



#pragma mark 底部视图的第二个界面
//------------------------颜色拾取------------------------

- (void)createQuseImageView {
    _quseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 40, kScreenWidth - 130 , 110)];
    _quseImageView.userInteractionEnabled = YES;
    _quseImageView.image = [UIImage imageNamed:@"quse"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedAction:)];
    [_quseImageView addGestureRecognizer:tapGesture];
    
}

- (void)tapGesturedAction:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:_quseImageView];
    
    
    if (location.x > 0 && location.x < _quseImageView.frame.size.width && location.y > 0 && location.y < _quseImageView.frame.size.height) {
        _textView.textColor = [_quseImageView colorOfPoint:location];
    }
    
    
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [_wenziScrollView viewWithTag:200 + i];
        button.selected = NO;
    }
}

- (void)createWenziScrollView {
    
    [self createQuseImageView];
    
    _wenziScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenWidth + 70, kScreenWidth , kScreenHeight - kScreenWidth - 70 - 64)];
    _wenziScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _wenziScrollView.hidden = YES;
    _wenziScrollView.contentSize = CGSizeMake(kScreenWidth, 160);
    
    [self.view addSubview:_wenziScrollView];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 40 + 60 * i, 50, 50)];
        
        button.tag = i + 200;
        
        [button setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateSelected];
        
        [_wenziScrollView addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction1:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            button.selected = YES;
            button.backgroundColor = [UIColor blackColor];
        }else {
            button.backgroundColor = [UIColor whiteColor];
        }
        
    }
    
    [_wenziScrollView addSubview:_quseImageView];
    
}

- (void)buttonAction1:(UIButton *)button {
    button.selected = YES;
    for (int i = 0; i < 2; i++) {
        UIButton *b = [_wenziScrollView viewWithTag:i+200];
        if (b.tag != button.tag) {
            b.selected = NO;
        }
    }
    switch (button.tag - 200) {
        case 0:
        {
            _textView.textColor = [UIColor blackColor];
            
            break;
        }
        case 1:
        {
            _textView.textColor = [UIColor whiteColor];
            
            break;
        }
            
            
        default:
            break;
    }
}


#pragma mark 底部视图的第三个界面


- (void)createBeijingScrollView {
    
    
    _beijingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenWidth + 70, kScreenWidth , kScreenHeight - kScreenWidth - 70 - 64)];
    _beijingScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _beijingScrollView.hidden = YES;
    _beijingScrollView.contentSize = CGSizeMake(kScreenWidth, 160);
    
    [self.view addSubview:_beijingScrollView];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i + 400;
        
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        [_beijingScrollView addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (i == 0) {
            [button setTitle:@"怀旧" forState:UIControlStateNormal];
            button.frame = CGRectMake(30, 30, kScreenWidth / 3, 50);
        }else if (i == 1) {
            [button setTitle:@"黑白" forState:UIControlStateNormal];
            button.frame = CGRectMake(kScreenWidth - 30 - kScreenWidth / 3, 30, kScreenWidth / 3, 50);
            
        }else if (i == 2) {
            [button setTitle:@"图片效果" forState:UIControlStateNormal];
            button.frame = CGRectMake(30, 110, kScreenWidth / 3, 50);
            
        }else {
            [button setTitle:@"图片效果" forState:UIControlStateNormal];
            button.frame = CGRectMake(kScreenWidth - 30 - kScreenWidth / 3, 110, kScreenWidth / 3, 50);
            
        }
        
        
    }

}

- (void)buttonAction2:(UIButton *)button {
    
    CIImage *inputImage = [CIImage imageWithCGImage:_faceView.image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    CIColor *color;
    
    switch (button.tag - 400) {
        case 0:
        {
            //NSLog(@"0");
            color = [CIColor colorWithRed:1.000 green:0.759 blue:0.592 alpha:1];
            break;
        }
        case 1:
        {
            //NSLog(@"1");
            color = [CIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1];
            break;
        }
        case 2:
        {
            //NSLog(@"2");
            //color = [CIColor colorWithRed:0.500 green:1.000 blue:0.500 alpha:1];
            break;
        }
        case 3:
        {
            //NSLog(@"3");
            //color = [CIColor colorWithRed:0.500 green:0.500 blue:1.000 alpha:1];
            break;
        }
            
        default:
            break;
    }

    
    [filter setValue:color forKey:kCIInputColorKey];
    //CIContext
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *outPutImage = filter.outputImage;
    
    CGImageRef image = [context createCGImage:outPutImage fromRect:outPutImage.extent];
    
    _faceView.image = [UIImage imageWithCGImage:image];

    
    
}


#pragma mark 底部视图的第四个界面
- (void)createZitiScrollView {
    
    _zitiScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenWidth + 70, kScreenWidth , kScreenHeight - kScreenWidth - 70 - 64)];
    _zitiScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _zitiScrollView.hidden = YES;
    _zitiScrollView.contentSize = CGSizeMake(kScreenWidth, 160);
    
    [self.view addSubview:_zitiScrollView];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i + 400;
        
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"字体效果" forState:UIControlStateNormal];
        
        [_zitiScrollView addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction3:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (i == 0) {
            button.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:22];
            button.frame = CGRectMake(30, 30, kScreenWidth / 3, 50);
        }else if (i == 1) {
            button.titleLabel.font = [UIFont fontWithName:@"STXingkai" size:22];
            button.frame = CGRectMake(kScreenWidth - 30 - kScreenWidth / 3, 30, kScreenWidth / 3, 50);
            
        }else if (i == 2) {
            button.titleLabel.font = [UIFont fontWithName:@"HYLeMiaoTiJ" size:22];
            button.frame = CGRectMake(30, 110, kScreenWidth / 3, 50);
            
        }else {
            button.titleLabel.font = [UIFont fontWithName:@"HYHeiLiZhiTiJ" size:22];
            button.frame = CGRectMake(kScreenWidth - 30 - kScreenWidth / 3, 110, kScreenWidth / 3, 50);
            
        }
        
        
    }
    
    
}

- (void)buttonAction3:(UIButton *)button {
    
    switch (button.tag - 400) {
        case 0:
        {
            _textView.font = [UIFont fontWithName:@"ArialMT" size:35];
            
            break;
        }
        case 1:
        {
            _textView.font = [UIFont fontWithName:@"STXingkai" size:35];
            
            break;
        }
        case 2:
        {
            _textView.font = [UIFont fontWithName:@"HYLeMiaoTiJ" size:35];
            
            break;
        }
        case 3:
        {
            _textView.font = [UIFont fontWithName:@"HYHeiLiZhiTiJ" size:35];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - 解析数据

- (void)loadData {
    
    if (_BGImage) {
        
        _imageView.image = [_BGImage copy];
        _faceView.image = [_faceImage copy];
        _textView.text = @"快来装逼啊";
        
        _isLoadData = YES;
        
        CGSize maximumLabelSize = CGSizeMake(kScreenWidth - 40, 9999);
        CGSize expectSize = [_textView sizeThatFits:maximumLabelSize];
        _textView.frame = CGRectMake(20, 70, expectSize.width, expectSize.height);
        _textView.center = _textViewCenter;
    }else {
        
        NSString *urlString = [NSString stringWithFormat:@"http://api.jiefu.tv/app2/api/dt/item/getDetail.html?itemId=%li",_emoticonId];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            NSMutableArray *mArray = [NSMutableArray array];
            NSDictionary *dictionary = responseObject[@"data"];
            NSDictionary *dic = dictionary[@"item"];
            EmoticonModel *model = [EmoticonModel yy_modelWithJSON:dic];
            [mDic setObject:model forKey:@"item"];
            NSArray *array = dictionary[@"list"];
            for (NSDictionary *d in array) {
                
                NSString *word = d[@"word"];
                [mArray addObject:word];
            }
            [mDic setObject:[mArray copy] forKey:@"list"];
            
            _dataDic = mDic;
            
            _isLoadData = YES;
            [_tableView reloadData];
            
            EmoticonModel *m = _dataDic[@"item"];
            
            //  设置图片和文字
            [_imageView sd_setImageWithURL:[NSURL URLWithString:m.gifPath]];
            
            _textView.text = m.name;
            CGSize maximumLabelSize = CGSizeMake(kScreenWidth - 40, 9999);
            CGSize expectSize = [_textView sizeThatFits:maximumLabelSize];
            _textView.frame = CGRectMake(20, 70, expectSize.width, expectSize.height);
            _textView.center = _textViewCenter;
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"失败");
            
        }];
        
    }
    
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_BGImage) {
        return _BGArray.count;
    }else {
        NSArray *array = _dataDic[@"list"];
        return array.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    if (_isLoadData) {
        
        if (_BGImage) {
            cell.textLabel.text = _BGArray[indexPath.row];
        } else {
            NSArray *array = _dataDic[@"list"];
            cell.textLabel.text = array[indexPath.row];
        }
        
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.backgroundColor = [UIColor colorWithRed:177 / 255.0 green:244 / 255.0 blue:177 / 255.0 alpha:0.5];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    
    
    cell.textLabel.highlightedTextColor = [UIColor greenColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_BGImage) {
        _textView.text = _BGArray[indexPath.row];
    } else {
        NSArray *array = _dataDic[@"list"];
        _textView.text = array[indexPath.row];
    }
    
    CGSize maximumLabelSize = CGSizeMake(kScreenWidth - 40, MAXFLOAT);
    CGSize expectSize = [_textView sizeThatFits:maximumLabelSize];
    CGPoint point = _textView.center;
    _textView.frame = CGRectMake(0, 0, expectSize.width, expectSize.height);
    
    _textView.center = point;
    
    
    
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    CGSize constraintSize = CGSizeMake(kScreenWidth - 40, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    CGPoint point = _textView.center;
    
    textView.frame = CGRectMake(0, 0, size.width, size.height);
    _textView.center = point;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
