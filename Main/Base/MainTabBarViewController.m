//
//  MainTabBarViewController.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/12.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController


#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createSubViewController];
        
        [self customTabBar];
    }
    return self;
}


- (void)createSubViewController {

    
    NSArray *storyboardName = @[@"Square",
                                @"Template",
                                @"Mine"];
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    for (NSString *sbName in storyboardName) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]];
        UINavigationController *navi = [storyboard instantiateInitialViewController];
        [mArray addObject:navi];
    }
    
    self.viewControllers = [mArray copy];
    
}

- (void)customTabBar {
    
    NSArray *array = @[@"guangchang",
                       @"moban",
                       @"wode"];
    NSArray *sArray = @[@"guangchanglv",
                       @"mobanlv",
                       @"wodelv"];
    
    
    for (UIView *subView in self.tabBar.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [subView removeFromSuperview];
        }
        
    }
    
    float width = kScreenWidth / 3;
    for (int i = 0; i < 3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width * i, 0, width, 49)];
        [button setImage:[UIImage imageNamed:array[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:sArray[i]] forState:UIControlStateSelected];
        button.tag = i + 100;
        if (i == 1) {
            button.selected = YES;
        }
        
        button.adjustsImageWhenHighlighted = NO;
        button.showsTouchWhenHighlighted = YES;
        
        [self.tabBar addSubview:button];
        
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    self.tabBar.backgroundImage = [UIImage imageNamed:@"menubg"];
    
    
    self.selectedIndex = 1;
}

- (void)buttonAction:(UIButton *)button {
    self.selectedIndex = button.tag - 100;
    button.selected = YES;
    for (int i = 0; i < 3; i++) {
        UIButton *b = [self.tabBar viewWithTag:i+100];
        if (b.tag != button.tag) {
            b.selected = NO;
        }
    }
}


#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
