//
//  NewViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/14.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "NewViewController.h"
#import "EmoticonCell.h"
#import "MakeViewController.h"

#define spaceWidth 10
#define picWidth ((kScreenWidth - 4 * spaceWidth) / 3) - 1


@interface NewViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    NSMutableArray *_dataArray;
    BOOL _isLoadData;
    NSInteger _pageNum;
}


@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [[NSMutableArray alloc] init];
    _isLoadData = NO;
    _pageNum = 0;
    self.title = @"最新模版";
    
    [self loadData];
    
    [self createCollectionView];

    
}

#pragma mark - 解析数据

- (void)loadData {
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.jiefu.tv/app2/api/dt/item/newList.html?pageNum=%li&pageSize=48", _pageNum];
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
    
    __weak NewViewController *weakSelf = self;
    // 添加上拉下拉刷新
    [_collectionView addPullDownRefreshBlock:^{
        __strong NewViewController *strongSelf = weakSelf;
        
        _pageNum = 0;
        // 下拉刷新
        [strongSelf loadData];
        
    }];
    
    // 上拉 加载更多
    [_collectionView addInfiniteScrollingWithActionHandler:^{
        __strong NewViewController *strongSelf = weakSelf;
        
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


#pragma mark -



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
