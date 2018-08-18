//
//  SearchViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/19.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "SearchViewController.h"
#import "EmoticonCell.h"

#define spaceWidth 10
#define picWidth ((kScreenWidth - 4 * spaceWidth) / 3) - 1

@interface SearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    UICollectionReusableView *_headerView;
    
    NSMutableArray *_dataArray;
    BOOL _isLoadData;
    NSInteger _pageNum;
    
    UITextField *_textField;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _titleText;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    _isLoadData = NO;
    
    
    [self loadData];
    
    [self createCollectionView];
}

#pragma mark - 解析数据

- (void)loadData {
    
    // 将中文进行urldecode编码
    NSString *encodingString = [_titleText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    //NSLog(@"%@ : %@", _titleText, encodingString);
    NSString *urlString = [NSString stringWithFormat:@"http://api.jiefu.tv/app2/api/dt/item/search.html?keyWord=%@&pageNum=%li&pageSize=48",encodingString, _pageNum];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        NSArray *array = responseObject[@"data"];
        
        for (NSDictionary *dic in array) {
            
            EmoticonModel *model = [EmoticonModel yy_modelWithJSON:dic];
            
            [mArray addObject:model];
            
        }
        if (_pageNum > 0) {
            [_collectionView.infiniteScrollingView stopAnimating];
            [_dataArray addObjectsFromArray:mArray];
        }else {
            [_collectionView.pullToRefreshView stopAnimating];
            _dataArray = mArray;
        }
        
        
        _isLoadData = YES;
        [_collectionView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"失败");
        
    }];
    
    
}


#pragma mark - 创建收藏视图

-(void)createCollectionView {
    
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.itemSize = CGSizeMake(picWidth, picWidth);
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    
    [_collectionView registerNib:[UINib nibWithNibName:@"EmoticonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellId"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headId"];
    
    __weak SearchViewController *weakSelf = self;
    // 添加上拉下拉刷新
    [_collectionView addPullDownRefreshBlock:^{
        __strong SearchViewController *strongSelf = weakSelf;
        
        _pageNum = 0;
        // 下拉刷新
        [strongSelf loadData];
        
    }];
    
    // 上拉 加载更多
    [_collectionView addInfiniteScrollingWithActionHandler:^{
        __strong SearchViewController *strongSelf = weakSelf;
        
        _pageNum += 1;
        // 上拉刷新
        [strongSelf loadData];
        
    }];
    
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EmoticonCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    if (_isLoadData) {
        cell.emoticon = _dataArray[indexPath.row];
    }
    
    
    // cell.backgroundColor = [UIColor redColor];
    cell.layer.cornerRadius = 7;
    
    return cell;
    
}


#pragma mark - 创建头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        _headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headId" forIndexPath:indexPath];
        if(_headerView == nil)
        {
            _headerView = [[UICollectionReusableView alloc] init];
        }
        _headerView.backgroundColor = [UIColor clearColor];
        
        [self createTopView];
        return _headerView;
    }
    return nil;
}

- (void)createTopView {
    
    UIView *searchView = [self createsearchView];
    [_headerView addSubview:searchView];

}
#pragma mark 搜索栏

-(UIView *)createsearchView {
    UIView *searchbgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    searchbgview.backgroundColor = [UIColor darkGrayColor];
    
    UIView *textbgView = [[UIView alloc]initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, 28)];
    textbgView.backgroundColor = [UIColor whiteColor];
    textbgView.layer.cornerRadius = 14.0;
    
    [searchbgview addSubview:textbgView];
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(14, 0, kScreenWidth - 60, 28)];
    _textField.placeholder = @"请输入搜索关键字";
    [textbgView addSubview:_textField];
    
    UIButton *searchbtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 52, 0, 28, 28)];
    [searchbtn setImage:[UIImage imageNamed:@"sousuogreen.png"] forState:UIControlStateNormal];
    [searchbtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [textbgView addSubview:searchbtn];
    return searchbgview;
}

-(void)searchAction:(UIButton *)button {
    
    // 匹配是否是不包含空白符的字符串
    NSString *regex = @"\\S+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isSearch = [predicate evaluateWithObject:_textField.text];
    if (isSearch) {
        
        self.title = _textField.text;
        _titleText = _textField.text;
        [self loadData];
        
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入搜索关键字";
        hud.margin = 10.f;
        hud.cornerRadius = 20;
        hud.yOffset = kScreenHeight / 3;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){kScreenWidth,44};
}




#pragma mark -
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MakeViewController *makeCtrl = [[MakeViewController alloc] init];
    EmoticonModel *emoticon = _dataArray[indexPath.row];
    
    makeCtrl.emoticonId = emoticon.emoticonId;
    
    
    [self.navigationController pushViewController:makeCtrl animated:YES];
}




@end
