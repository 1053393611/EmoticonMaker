//
//  ClassTwoViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/14.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "ClassTwoViewController.h"
#import "PersonCell.h"
#import "PersonEmoticonViewController.h"


#define spaceWidth 6
#define  picWidth ((kScreenWidth - 7.0 * spaceWidth) / 4.0)

@interface ClassTwoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    UICollectionReusableView *_headerView;
    

    NSMutableArray *_dataArray;
    
    BOOL _isLoadData;
    
    UITextField *textField;
}


@end

@implementation ClassTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStylePlain target: nil action: nil];

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
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    
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
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize cellSize;
    if (indexPath.section == 5 || _issearch == YES) {
        cellSize = CGSizeMake(picWidth, 42);
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
        _headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        for(UIView *view in _headerView.subviews) {
            [view removeFromSuperview];
        }
        UIView *hdbgView = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenWidth, 28)];
        if (indexPath.section == 0) {
            if (_issearch == YES) {
                hdbgView.frame = CGRectMake(0, 51, kScreenWidth, 28);
                UIView *searchView = [self createsearchView];
                [_headerView addSubview:searchView];
            }else {
                hdbgView.frame = CGRectMake(0, 0, kScreenWidth, 28);
            }
        }
        hdbgView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, kScreenWidth - 35, 20)];
        [hdbgView addSubview:imageView];
        [hdbgView addSubview:label];
        [_headerView addSubview:hdbgView];
        imageView.image = [UIImage imageNamed:@"lanmuicon"];
        
        
        label.text = _dataArray[indexPath.section][@"name"];
       
        label.textColor = [UIColor grayColor];
        
        
        return _headerView;
    }
    return nil;
}

#pragma mark -搜索栏

-(UIView *)createsearchView {
    UIView *searchbgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    searchbgview.backgroundColor = [UIColor darkGrayColor];
    
    UIView *textbgView = [[UIView alloc]initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, 28)];
    textbgView.backgroundColor = [UIColor whiteColor];
    textbgView.layer.cornerRadius = 14.0;
    
    [searchbgview addSubview:textbgView];
    
    textField = [[UITextField alloc]initWithFrame:CGRectMake(14, 0, kScreenWidth - 60, 28)];
    textField.placeholder = @"请输入搜索关键字";
    [textbgView addSubview:textField];
    
    UIButton *searchbtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 52, 0, 28, 28)];
    [searchbtn setImage:[UIImage imageNamed:@"sousuogreen.png"] forState:UIControlStateNormal];
    [searchbtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [textbgView addSubview:searchbtn];
    return searchbgview;
}
//mhttp://api.jiefu.tv/app2/api/dt/shareItem/search.html?keyWord=j&pageNum=0&pageSize=48
-(void)searchAction {
    
        NSString *regex = @"\\S+";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL iss = [predicate evaluateWithObject:textField.text];
        if (iss) {
            PersonEmoticonViewController *pevc = [[PersonEmoticonViewController alloc]initWithName:textField.text tagId:0];
            pevc.isSearch = YES;
            [self.navigationController pushViewController:pevc animated:YES];
        }else {
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

#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (_issearch == YES) {
            return (CGSize){kScreenWidth,79};
        }else{
            return (CGSize){kScreenWidth,28};
        }
        
    }else {
        return (CGSize){kScreenWidth,35};
    }
    
}


#pragma mark -
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(spaceWidth, spaceWidth, spaceWidth,spaceWidth);
}

#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    SortViewController *sortCtrl = [[SortViewController alloc] init];
    NSArray *array = _dataArray[indexPath.section][@"model"];
    EmoticonModel *model = array[indexPath.row];
//    sortCtrl.emoticonId = emoticon.emoticonId;
//    sortCtrl.titleText = emoticon.name;
//
    PersonEmoticonViewController *peVC = [[PersonEmoticonViewController alloc]initWithName:model.name tagId:model.emoticonId];
    [self.navigationController pushViewController:peVC animated:YES];
//    [self.navigationController pushViewController:sortCtrl animated:YES];
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
