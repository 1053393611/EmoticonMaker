//
//  ClassViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/14.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "ClassViewController.h"
#import "PersonCell.h"
#import "SortViewController.h"

#define spaceWidth 10
#define picWidth ((kScreenWidth - 4 * spaceWidth) / 3) - 1

@interface ClassViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    UICollectionReusableView *_headerView;
    

    NSMutableArray *_dataArray;
    
    BOOL _isLoadData;

}


@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.title = @"分类";

    _dataArray = [[NSMutableArray alloc] init];

    _isLoadData = NO;

    
    [self loadData];
    
    [self createCollectionView];
    
    
}

#pragma mark - 解析数据

- (void)loadData {
    
    
    NSString *urlString = @"http://api.jiefu.tv/app2/api/dt/tag/allList.html";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSMutableArray *mArray = [NSMutableArray array];
        NSArray *array = responseObject[@"data"];
        
        for (NSDictionary *dic in array) {
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            NSDictionary *dictionary = dic[@"dtTypeModel"];
            NSString *name = dictionary[@"name"];

            [mDic setObject:name forKey:@"name"];
            
            NSMutableArray *mmArray = [NSMutableArray array];
            for (NSDictionary *d in dic[@"tagList"]) {
                EmoticonModel *model = [EmoticonModel yy_modelWithJSON:d];
                [mmArray addObject:model];
                
            }
            [mDic setObject:mmArray forKey:@"model"];
            
            [mArray addObject:mDic];
        }

        _dataArray = mArray;
        
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
    
    _collectionView.bounces = NO;
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    
    [_collectionView registerNib:[UINib nibWithNibName:@"PersonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellId"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"classHeadId"];
    
    
}


#pragma mark - UICollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *array = _dataArray[section][@"model"];
    return array.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PersonCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    
    
    if (_isLoadData) {
        NSArray *array = _dataArray[indexPath.section][@"model"];
        cell.emoticon = array[indexPath.row];
    }

    
    cell.layer.cornerRadius = 7;
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize cellSize;
    if (indexPath.section == 5) {
        cellSize = CGSizeMake(picWidth, 45);
    }else {
         cellSize = CGSizeMake(picWidth, picWidth);
    }
    return cellSize;
}


#pragma mark - 创建头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
     
        _headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"classHeadId" forIndexPath:indexPath];
        if(_headerView == nil)
        {
            _headerView = [[UICollectionReusableView alloc] init];
          
        }
        _headerView.backgroundColor = [UIColor clearColor];
        
        for(UIView *view in _headerView.subviews) {
            [view removeFromSuperview];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 100, 20)];
        
        [_headerView addSubview:imageView];
        [_headerView addSubview:label];
        
        imageView.image = [UIImage imageNamed:@"lanmuicon"];
        
        
        label.text = _dataArray[indexPath.section][@"name"];
       
        label.textColor = [UIColor grayColor];
        
        
        return _headerView;
    }
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    return (CGSize){kScreenWidth,30};
    
}


#pragma mark -
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SortViewController *sortCtrl = [[SortViewController alloc] init];
    NSArray *array = _dataArray[indexPath.section][@"model"];
    EmoticonModel *emoticon = array[indexPath.row];
    sortCtrl.emoticonId = emoticon.emoticonId;
    sortCtrl.titleText = emoticon.name;
    
    [self.navigationController pushViewController:sortCtrl animated:YES];
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
