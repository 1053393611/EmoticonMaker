//
//  TemplateViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/12.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "TemplateViewController.h"
#import "EmoticonCell.h"
#import "HotViewController.h"
#import "ClassViewController.h"
#import "NewViewController.h"
#import "GIFViewController.h"
#import "HelpViewController.h"
#import "MakeViewController.h"
#import "SearchViewController.h"

#define spaceWidth 10
#define picWidth ((kScreenWidth - 4 * spaceWidth) / 3) - 1

@interface TemplateViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_flowLayout;
    UICollectionReusableView *_headerView;
    
    NSMutableArray *_dataArray;
    BOOL _isLoadData;
    NSInteger _pageNum;
    
    UITextField *_textField;
    UIImagePickerController *_picker;
}

@end

@implementation TemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _dataArray = [[NSMutableArray alloc] init];
    _isLoadData = NO;
    _pageNum = 0;
    
    [self loadData];
    
    [self createNavigationBarButtonItem];
    
    [self createCollectionView];
    
    
}

#pragma mark - 解析数据

- (void)loadData {
    
 
    NSString *urlString = [NSString stringWithFormat:@"http://api.jiefu.tv/app2/api/dt/item/recommendList.html?pageNum=%li&pageSize=48", _pageNum];
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


#pragma mark - NavigationBarButtonItem
- (void)createNavigationBarButtonItem {
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button1 setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    self.navigationItem.leftBarButtonItem = left;
    
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button2 setImage:[UIImage imageNamed:@"xiangji"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.navigationItem.rightBarButtonItem = right;
    
}

- (void)helpAction {
    
    HelpViewController *helpCtrl = [[HelpViewController alloc] init];
    helpCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:helpCtrl animated:YES];
    
}

- (void)cameraAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请保存照片" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"从相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //响应回调
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self getPhoto];
        }
        
    }];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"从图库选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //响应回调
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self getPhoto];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [alertController addAction:archiveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 得到图片

-(void)getPhoto
{

    _picker = [[UIImagePickerController alloc] init];
    
    _picker.delegate = self;
    [self presentViewController:_picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    MakeViewController *makeCtrl = [[MakeViewController alloc] init];
    makeCtrl.BGImage = image;
    
    makeCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:makeCtrl animated:YES];
    
}


#pragma mark - 创建收藏视图

-(void)createCollectionView {
    
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.itemSize = CGSizeMake(picWidth, picWidth);
 
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    
    [_collectionView registerNib:[UINib nibWithNibName:@"EmoticonCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellId"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headId"];
    
    
    __weak TemplateViewController *weakSelf = self;
    // 添加上拉下拉刷新
    [_collectionView addPullDownRefreshBlock:^{
        __strong TemplateViewController *strongSelf = weakSelf;
        
        _pageNum = 0;
        // 下拉刷新
        [strongSelf loadData];
        
    }];
    
    // 上拉 加载更多
    [_collectionView addInfiniteScrollingWithActionHandler:^{
        __strong TemplateViewController *strongSelf = weakSelf;
        
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
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 70)];
    view.userInteractionEnabled = YES;
    view.image = [UIImage imageNamed:@"mobantopbg"];
    
    [_headerView addSubview:view];
    UIView *searchView = [self createsearchView];
    [_headerView addSubview:searchView];
    
    NSArray *bArray = @[@"remen", @"zhizuodafenlei", @"zuixin", @"dongtai"];
    float width = kScreenWidth / 4;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width * i, 0, width, 70)];
        [button setImage:[UIImage imageNamed:bArray[i]] forState:UIControlStateNormal];
        
        button.tag = i + 100;

        [view addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 120, 20, 20)];
    imageView.image = [UIImage imageNamed:@"lanmuicon"];
    [_headerView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 120, 100, 20)];
    label.text = @"推荐模板";
    label.textColor = [UIColor grayColor];
    [_headerView addSubview:label];

}


- (void)buttonAction:(UIButton *)button {
    switch (button.tag - 100) {
        case 0:
        {
            HotViewController *hotCtr = [[HotViewController alloc] init];
            hotCtr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:hotCtr animated:YES];
            break;
        }
        case 1:
        {
            ClassViewController *classCtr = [[ClassViewController alloc] init];
            classCtr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:classCtr animated:YES];
            break;
        }
        case 2:
        {
            NewViewController *newCtr = [[NewViewController alloc] init];
            newCtr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newCtr animated:YES];
            break;
        }
        case 3:
        {
            GIFViewController *gifCtr = [[GIFViewController alloc] init];
            gifCtr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:gifCtr animated:YES];
            break;
        }
        default:
            break;
    }
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
        SearchViewController *searchCtr = [[SearchViewController alloc] init];
        searchCtr.hidesBottomBarWhenPushed = YES;
        searchCtr.titleText = _textField.text;
        [self.navigationController pushViewController:searchCtr animated:YES];
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
    return (CGSize){kScreenWidth,144};
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

    makeCtrl.hidesBottomBarWhenPushed = YES;
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
