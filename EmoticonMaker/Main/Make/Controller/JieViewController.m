//
//  JieViewController.m
//  EmoticonMaker
//
//  Created by mac on 2017/5/16.
//  Copyright © 2017年 mac14. All rights reserved.
//

#import "JieViewController.h"

@interface JieViewController (){
    CGRect faceFrame;
    UIImage *faceImage;
}

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation JieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStylePlain target: nil action: nil];
    self.title = @"人脸";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    _imgView.image = _BGImage;
    [self.view addSubview:_imgView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth + 100, 100, 200, 100)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"123" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i + 400;
        
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        [self.view addSubview:button];
        
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (i == 0) {
            [button setTitle:@"人脸检测" forState:UIControlStateNormal];
            button.frame = CGRectMake(30, kScreenWidth + 30, kScreenWidth / 3, 50);
        }else if (i == 1) {
            [button setTitle:@"作为背景" forState:UIControlStateNormal];
            button.frame = CGRectMake(kScreenWidth - 30 - kScreenWidth / 3,kScreenWidth + 30, kScreenWidth / 3, 50);
            
        }
        
        
    }

    
   // [self action];
    
}

-(void)action:(UIButton *)button {
    
    switch (button.tag - 400) {
        case 0:
        {
            [self beginDetectorFacewithImage:_BGImage];
            for (UIView *view in self.imgView.subviews) {
                [view removeFromSuperview];
            }
            faceImage = [UIImage imageWithView:self.imgView];
            self.imgView.image = faceImage;
            
            
            JPGViewController *jpgCtrl = [[JPGViewController alloc] init];
            jpgCtrl.faceImage = [UIImage ct_imageFromImage:self.imgView.image inRect:faceFrame];
            //jpgCtrl.faceImage = self.imgView.image;
            [self.navigationController pushViewController:jpgCtrl animated:YES];
            
            break;
        }
        case 1:
        {
            MakeViewController *makeCtrl = [[MakeViewController alloc] init];
            
            
            makeCtrl.BGImage = _imgView.image;
            
            makeCtrl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:makeCtrl animated:YES];
            
            break;
        }
            
        default:
            break;
    }

    
    
}


- (void)beginDetectorFacewithImage:(UIImage *)image
{
    
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    
    
    float factor = self.imgView.bounds.size.width/image.size.width;
    ciimage = [ciimage imageByApplyingTransform:CGAffineTransformMakeScale(factor, factor)];
    
    
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:opts];
    
    NSArray* features = [detector featuresInImage:ciimage];
    
    
    for (CIFaceFeature *faceFeature in features){
        
        

        CGFloat faceWidth = faceFeature.bounds.size.width;
        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.frame = CGRectMake(faceView.frame.origin.x, self.imgView.bounds.size.height-faceView.frame.origin.y - faceView.bounds.size.height, faceView.frame.size.width, faceView.frame.size.height);
        
        float x = 0.0, y, width, height;
        faceFrame = faceView.frame;
        
        
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [self.imgView addSubview:faceView];
        // 标出左眼
        if(faceFeature.hasLeftEyePosition) {
            UIView* leftEyeView = [[UIView alloc] initWithFrame:
                                   CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15,
                                              self.imgView.bounds.size.height-(faceFeature.leftEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3)];
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            //            [leftEyeView setCenter:faceFeature.leftEyePosition];
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            [self.imgView  addSubview:leftEyeView];
            x = faceFeature.leftEyePosition.x - faceWidth*0.15;
        }
        // 标出右眼
        if(faceFeature.hasRightEyePosition) {
            UIView* leftEye = [[UIView alloc] initWithFrame:
                               CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                          self.imgView.bounds.size.height-(faceFeature.rightEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3)];
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            leftEye.layer.cornerRadius = faceWidth*0.15;
            [self.imgView  addSubview:leftEye];
            
        }
        
        if ((self.imgView.bounds.size.height-(faceFeature.leftEyePosition.y-faceWidth*0.15)-faceWidth*0.3) < (self.imgView.bounds.size.height-(faceFeature.rightEyePosition.y-faceWidth*0.15)-faceWidth*0.3)) {
            y = self.imgView.bounds.size.height-(faceFeature.leftEyePosition.y-faceWidth*0.15)-faceWidth*0.3;
        }else {
            y = self.imgView.bounds.size.height-(faceFeature.rightEyePosition.y-faceWidth*0.15)-faceWidth*0.3;
        }
        width = faceFeature.rightEyePosition.x - faceFeature.leftEyePosition.x + faceWidth*0.3;
        
        // 标出嘴部
        if(faceFeature.hasMouthPosition) {
            UIView* mouth = [[UIView alloc] initWithFrame:
                             CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                        self.imgView.bounds.size.height-(faceFeature.mouthPosition.y-faceWidth*0.2)-faceWidth*0.4, faceWidth*0.4, faceWidth*0.4)];
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            
            mouth.layer.cornerRadius = faceWidth*0.2;
            [self.imgView  addSubview:mouth];
        }
        
        if (faceFeature.rightEyePosition.y > faceFeature.leftEyePosition.y) {
            height = faceFeature.rightEyePosition.y - faceFeature.mouthPosition.y + faceWidth * 0.4;
        }else {
            height = faceFeature.leftEyePosition.y - faceFeature.mouthPosition.y + faceWidth * 0.3;
        }
        
        faceFrame = CGRectMake(x, y, width, height);
        
    }
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
