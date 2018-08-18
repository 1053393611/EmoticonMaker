//
//  JPGViewController.m
//  EmoticonMaker
//
//  Created by mac on 2017/5/16.
//  Copyright © 2017年 mac14. All rights reserved.
//

#import "JPGViewController.h"
#import "FaceViewController.h"

#define spaceWidth 10
#define picWidth ((kScreenWidth - 4 * spaceWidth) / 3) - 1

@interface JPGViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>{
    UICollectionViewFlowLayout *flowLayout;
    
}
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation JPGViewController

static NSString *const cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStylePlain target: nil action: nil];
    self.title = @"模版";
    
    [self _loadCollectionView];
}



#pragma mark- 创建collectionView
-(void)_loadCollectionView {
    
    flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(picWidth, picWidth);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:flowLayout];
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
    return 20;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor orangeColor];
    cell.layer.cornerRadius = 5;
    
  
    cell.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",indexPath.row]];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    
    FaceViewController *makeCtrl = [[FaceViewController alloc] init];
    makeCtrl.BGImage = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",indexPath.row]];;
    //makeCtrl.emoticonId = 0;
    
    makeCtrl.faceImage = self.faceImage;
    
    makeCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:makeCtrl animated:YES];

    
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
