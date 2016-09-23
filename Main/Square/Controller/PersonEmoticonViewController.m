//
//  PersonEmoticonViewController.m
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/18.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "PersonEmoticonViewController.h"

#define apiurl1 @"http://api.jiefu.tv/app2/api/dt/shareItem/getByTag.html"
#define apiurl2 @"http://api.jiefu.tv/app2/api/dt/shareItem/search.html"
#define spaceWidth 6
#define  picWidth ((kScreenWidth - 7.0 * spaceWidth) / 4.0)
@interface PersonEmoticonViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    NSInteger pageNum;
    NSMutableArray *_imagearray;
    TanChuKuang *tanchuview;
    
    UITextField *textField;
    UICollectionReusableView *_headerView;
}
@end

@implementation PersonEmoticonViewController

static NSString *const cellId = @"cellId";

-(instancetype)initWithName:(NSString *)name tagId:(NSInteger) tagId
{
    self = [super init];
    if (self) {
        self.personname = name;
        self.tagId = tagId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.personname;
    pageNum = 0;
    [self _loadDate];
    [self _loadCollectionView];
    __weak PersonEmoticonViewController *weakself = self;
    [_collectionView addInfiniteScrollingWithActionHandler:^{
        __strong PersonEmoticonViewController *strongself = weakself;
        [strongself loadMoreData];
    }];
    tanchuview = [[TanChuKuang alloc]init];
    [self.navigationController.view addSubview:tanchuview];
    tanchuview.hidden = YES;
}

-(void)_loadDate {
    //http://api.jiefu.tv/app2/api/dt/shareItem/getByTag.html?tagId=5&pageNum=1&pageSize=48
    NSString *url;
    if (_isSearch == YES) {
        NSString *encodingString = [_personname stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        url = [NSString stringWithFormat:@"%@?keyWord=%@&pageNum=%li&pageSize=48", apiurl2, encodingString, pageNum];
        //NSLog(@"%@",url);
    }else {
        url = [NSString stringWithFormat:@"%@?tagId=%li&pageNum=%li&pageSize=48", apiurl1, _tagId, pageNum];
    }
    
    //NSLog(@"%@",url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *array = responseObject[@"data"];
        NSMutableArray *mutarray = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            EmoticonModel *model = [EmoticonModel yy_modelWithJSON:dic];
            [mutarray addObject:model];
        }
        NSMutableArray *marray = [mutarray mutableCopy];
        if (_imagearray != nil) {
            [_imagearray addObjectsFromArray:[marray mutableCopy]];
        }else {
            _imagearray = [marray mutableCopy];
        }
        
        [_collectionView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

-(void)loadMoreData{
    
    pageNum++;
    [self _loadDate];
    
    [_collectionView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2.0];
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
        _imagearray = nil;
        pageNum = 0;
        self.personname = textField.text;
        [self _loadDate];
        self.title = textField.text;
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
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"classHeadId"];
    
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
        if (_isSearch == YES) {
            UIView *searchView = [self createsearchView];
            [_headerView addSubview:searchView];
        }
        

        return _headerView;
    }
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [tanchuview show:_imagearray[indexPath.row]];
    __weak PersonEmoticonViewController *weakself = self;
    
    [tanchuview setBlock:^(EmoticonModel *model) {
        __strong PersonEmoticonViewController *strongself = weakself;
        MakeViewController *makeCtrl = [[MakeViewController alloc] init];
        
        makeCtrl.emoticonId = model.itemId;
        
        makeCtrl.hidesBottomBarWhenPushed = YES;
        [strongself.navigationController pushViewController:makeCtrl animated:YES];
    }];
}
#pragma mark - uicollection flowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){picWidth,picWidth};
}

#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
        if (_isSearch == YES) {
            return (CGSize){kScreenWidth,44};
        }else{
            return (CGSize){kScreenWidth,0};
        }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(spaceWidth, spaceWidth, spaceWidth,spaceWidth);
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
