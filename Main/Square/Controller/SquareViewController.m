//
//  SquareViewController.m
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/12.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "SquareViewController.h"
#import "PersonEmoticonViewController.h"
#import "ClassTwoViewController.h"
#import "EmoticonCell.h"

#define spaceWidth 6
#define  picWidth ((kScreenWidth - 7.0 * spaceWidth) / 4.0)

#define headerurl @"http://api.jiefu.tv/app2/api/dt/tag/hotList.html?pageSize=7"
#define tailurl @"http://api.jiefu.tv/app2/api/dt/shareItem/newList.html"

@interface SquareViewController()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    UICollectionReusableView *headerView;
    NSInteger pageNum;
    TanChuKuang *tanchuview;
}
@property (nonatomic , strong) NSMutableArray *tuijianarray;
@property (nonatomic , strong) NSMutableArray *imagearray;
@end

@implementation SquareViewController

static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";

-(void)viewDidLoad {
    self.title = @"大家都在发";
    [self _createRightBarBtn];
    [self _loadCollectionView];
    [self _loadDate:tailurl];
    [self _loadDate: headerurl];
    __weak SquareViewController *weakself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{
        __strong SquareViewController *strongself = weakself;
        [strongself loadMoreData];
    }];
    pageNum = 0;
    tanchuview = [[TanChuKuang alloc]init];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:tanchuview];
    tanchuview.hidden = YES;
}

-(void)_createRightBarBtn {
    
    self.navigationController.navigationBar.translucent = NO;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"sousuowhite"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(searchBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barBtn;
    
}

-(void)searchBtn {
    
    ClassTwoViewController *cvc = [[ClassTwoViewController alloc]init];
    cvc.issearch = YES;
    cvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cvc animated:YES];
    
}

-(void)_loadDate:(NSString *) url {
    if (![url isEqualToString:headerurl]) {
        url = [NSString stringWithFormat:@"%@?pageNum=%li&pageSize=48",tailurl,pageNum];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *array = responseObject[@"data"];
        NSMutableArray *mutarray = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            EmoticonModel *model = [EmoticonModel yy_modelWithJSON:dic];
            [mutarray addObject:model];
        }
        if (![url isEqualToString:headerurl]) {
            NSMutableArray *array = [mutarray mutableCopy];
            if (_imagearray != nil) {
//                [_imagearray arrayByAddingObjectsFromArray:array];
                [_imagearray addObjectsFromArray:[array mutableCopy]];
            }else {
                _imagearray = [array mutableCopy];
            }
        }else {
            NSMutableArray *array = [mutarray mutableCopy];
            if (_tuijianarray != nil) {
                [_tuijianarray arrayByAddingObjectsFromArray:array];
            }else {
                _tuijianarray = [array mutableCopy];
            }
        }
        
        [_collectionView reloadData];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

-(void)loadMoreData{
    
    pageNum++;
    [self _loadDate:tailurl];
    
    [_collectionView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2.0];
}
#pragma mark- 创建collectionView
-(void)_loadCollectionView {
    
    flowLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"EmoticonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
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
    if (_imagearray != nil) {
        cell.emoticon = _imagearray[indexPath.row];
        cell.textLabel.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [tanchuview show:_imagearray[indexPath.row]];
    __weak SquareViewController *weakself = self;
    
    [tanchuview setBlock:^(EmoticonModel *model) {
        __strong SquareViewController *strongself = weakself;
        MakeViewController *makeCtrl = [[MakeViewController alloc] init];
        
        makeCtrl.emoticonId = model.itemId;
        
        makeCtrl.hidesBottomBarWhenPushed = YES;
        [strongself.navigationController pushViewController:makeCtrl animated:YES];
    }];
    
}
#pragma mark - 头视图
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor clearColor];
    CGFloat gdheight = ((kScreenWidth - 5.0 * spaceWidth) / 4.0) * 2 + spaceWidth * 3.0;
    UIView *gdview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, gdheight)];
    gdview.backgroundColor = [UIColor whiteColor];
    if (_tuijianarray != nil) {
        for (int i = 0 ; i <= _tuijianarray.count ; i++) {
            if (i != _tuijianarray.count) {
                UIView *smallview = [self createsmallpic:_tuijianarray[i] num:i + 1];
                [gdview addSubview:smallview];
            }else {
                UIView *smallview = [self createsmallpic:nil num:i + 1];
                [gdview addSubview:smallview];
            }
            
        }
    }
    [headerView addSubview:gdview];
    //------------
    UIView *newview = [[UIView alloc]initWithFrame:CGRectMake(0, gdheight, kScreenWidth, 27)];
    UIImageView *lanmuicon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
    lanmuicon.image = [UIImage imageNamed:@"lanmuicon@2x"];
    [newview addSubview:lanmuicon];
    UILabel *newlabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 5, kScreenWidth - 40, 20)];
    newlabel.text = @"今日最新表情";
    [newview addSubview:newlabel];
    newlabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:newview];
    
    return headerView;
}

-(UIView *)createsmallpic:(EmoticonModel *) model num:(NSInteger)num{
    CGFloat width = (kScreenWidth - 5.0 * spaceWidth) / 4.0;
    UIView *smallview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(22, 12, width - 22 * 2, width - 2 * 22)];
    [smallview addSubview:imgview];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, width - 26, width, 20)];
    if (model != nil) {
        [imgview sd_setImageWithURL:[NSURL URLWithString:model.picPath]];
        label.text = model.name;
    }else {
        imgview.image = [UIImage imageNamed:@"zhizuofenlei@2x"];
        label.text = @"更多";
    }
    label.textColor = [UIColor grayColor];
    label.textAlignment =  NSTextAlignmentCenter;
    [smallview addSubview:label];
    
    NSInteger hang = (num - 1) / 4;
    NSInteger low = num % 4 - 1;
    if (low < 0) {
        low = 3;
    }
    smallview.frame = CGRectMake(spaceWidth  + (spaceWidth + width) * low, spaceWidth + (spaceWidth + width) * hang, width, width);
    smallview.layer.cornerRadius = 8.0;
    smallview.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    smallview.layer.borderWidth = 2.0;
    smallview.tag = 110 + num;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gengduotiaozhaun:)];
    [smallview addGestureRecognizer:tapGes];
    
    return smallview;
}

#pragma mark - 手势响应
-(void)gengduotiaozhaun:(UITapGestureRecognizer *) tapGes{
    
    NSInteger tagnum = tapGes.view.tag - 110 - 1;
    
    if (tagnum < 7) {
//        NSLog(@"手势111 ,%@",_tuijianarray[tagnum]);
        EmoticonModel *model = _tuijianarray[tagnum];
        PersonEmoticonViewController *peVC = [[PersonEmoticonViewController alloc]initWithName:model.name tagId:model.emoticonId];
        peVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:peVC animated:YES];
    }else {
        ClassTwoViewController *cvc = [[ClassTwoViewController alloc]init];
        cvc.hidesBottomBarWhenPushed = YES;
        cvc.issearch = NO;
        [self.navigationController pushViewController:cvc animated:YES];
        
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return (CGSize){kScreenWidth, ((kScreenWidth - 5.0 * spaceWidth) / 4.0) * 2 + spaceWidth * 3.0 + 27};
}

@end
