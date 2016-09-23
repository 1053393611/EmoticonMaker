//
//  PersonEmoticonViewController.m
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/18.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "MineViewController.h"
#import "UIImage+GIF.h"
#import "OpenShareHeader.h"

#define spaceWidth 6
#define  picWidth ((kScreenWidth - 7.0 * spaceWidth) / 4.0)

@interface MineViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    NSArray *_imagearray;
    NSArray *_imageType;
    NSDictionary *_imageDic;
    NSString *_currentImageKey;
    UICollectionReusableView *_headerView;
    NSString *path;
    UIAlertController *tanchuview;
    NSString *scImagePath;
    
    
    UIImage *testImage,*testThumbImage;
}
@end

@implementation MineViewController

static NSString *const cellId = @"cellId";

-(instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.personname = name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.personname;
    
    
    if ([_personname isEqualToString:@"我收藏的"] ) {
        scImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shoucang"];
    } else if ([_personname isEqualToString:@"我制作的"] ) {
        scImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baocun"];
    }
    
    [self _loadDate];
    [self _loadCollectionView];
    UIButton *scbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [scbtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    [scbtn addTarget:self action:@selector(shanchuqunbu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:scbtn];
    self.navigationItem.rightBarButtonItem = rightbtn;
}

-(void)shanchuqunbu {
    tanchuview = [UIAlertController alertControllerWithTitle:@"清除表单" message:@"你确认全部清除这些表情吗？" preferredStyle:UIAlertControllerStyleAlert];
    [tanchuview addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tanchuview addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:scImagePath error:nil];
        _imageDic = nil;
        _imagearray = nil;
        _imageType = nil;
        [_collectionView reloadData];
    }]];
    [self presentViewController:tanchuview animated:YES completion:nil];
    
}

-(void)_loadDate {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *dataPath = [scImagePath stringByAppendingPathComponent:@"dataArray"];
    
    if ([manager fileExistsAtPath:dataPath]) {
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        _imageDic = dic;
        _imagearray = [dic allKeys];
        _imageType = [dic allValues];
    }
    
}

#pragma mark- 创建collectionView
-(void)_loadCollectionView {
    
    flowLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
//    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [_collectionView registerNib:[UINib nibWithNibName:@"EmoticonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
}
#pragma mark - uicollectionview detasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imagearray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor orangeColor];
    cell.layer.cornerRadius = 5;
    if ([_imageType[indexPath.row] integerValue] == 1) {
        NSURL *url = [NSURL fileURLWithPath:[scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",_imagearray[indexPath.row]]]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.bgImageView.image = [UIImage sd_animatedGIFWithData:data];
    }else {
        cell.bgImageView.image = [UIImage imageWithContentsOfFile:[scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_imagearray[indexPath.row]]]];
        
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_imageType[indexPath.row] integerValue] == 1) {
        path = [scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",_imagearray[indexPath.row]]];
    }else {
        path = [scImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_imagearray[indexPath.row]]];
        testImage = [UIImage imageNamed:@"icon"];
        testThumbImage = [UIImage imageWithContentsOfFile:path];
    }
    _currentImageKey = _imagearray[indexPath.row];
    [self createtanchu];
}

- (void)createtanchu {
    
    tanchuview = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIView *smallview = [[UIView alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth - 20, 85)];
//    smallview.backgroundColor = [UIColor redColor];
    [tanchuview.view addSubview:smallview];
    
    NSArray *array = @[@"微信",@"QQ",@"删除"];
    NSArray *imgarray = @[@"qqshare",@"wechat",@"del"];
//    CGFloat btnwidth = 50.0;
    CGFloat space = (kScreenWidth - 150 - 20) / 4.0;
    for (int i = 0; i < 3; i ++) {
        UIView *btnview = [[UIView alloc]initWithFrame:CGRectMake(space + (50 + space) * i, 10, 50, 70)];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//        button.backgroundColor = [UIColor redColor];
        [button setBackgroundImage:[UIImage imageNamed:imgarray[i]] forState:UIControlStateNormal];
//        [button setTitle:array[i] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
        label.text = array[i];
        label.textAlignment = NSTextAlignmentCenter;
        [btnview addSubview:label];
        [btnview addSubview:button];
        [smallview addSubview:btnview];
    }
    
    [tanchuview addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:tanchuview animated:YES completion:nil];
}

-(void)buttonAction:(UIButton *)btn {
    if (btn.tag == 100) {
        NSLog(@"微信");
        [self dismissViewControllerAnimated:YES completion:nil];
        [self shareAction];
        
    }else if (btn.tag == 101) {
        NSLog(@"QQ");
    }else if (btn.tag == 102) {
        NSLog(@"删除");
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:path error:nil];
        
        NSString *dataPath = [scImagePath stringByAppendingPathComponent:@"dataArray"];
        NSMutableDictionary *mudic = [_imageDic mutableCopy];
        [mudic removeObjectForKey:_currentImageKey];
        _imageDic = [mudic copy];
        _imagearray = [_imageDic allKeys];
        _imageType = [_imageDic allValues];
        NSData *data = [NSJSONSerialization dataWithJSONObject:mudic options:NSJSONWritingPrettyPrinted error:nil];
        [data writeToFile:dataPath atomically:YES];
        [_collectionView reloadData];
        [tanchuview dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - uicollection flowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){picWidth,picWidth};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(spaceWidth, spaceWidth, spaceWidth,spaceWidth);
}


#pragma mark - 分享
- (void)shareAction {
    
    [OpenShare connectWeixinWithAppId:@"wxd930ea5d5a258f4f"];
    OSMessage *msg = [[OSMessage alloc]init];
    msg.image = testImage;
    msg.thumbnail = testThumbImage;

    [OpenShare shareToWeixinSession:msg Success:^(OSMessage *message) {
        NSLog(@"微信分享到会话成功：\n%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"微信分享到会话失败：\n%@\n%@",error,message);
    }];
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
