//
//  MineTableViewController.m
//  lanrenzhoumo
//
//  Created by mac15 on 16/9/20.
//  Copyright © 2016年 jin. All rights reserved.
//

#import "MineTableViewController.h"
#import "MineViewController.h"

@interface MineTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;
@end

@implementation MineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self readCacheSize];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"发送");
                break;
            case 1: {
                // NSLog(@"制作");
                MineViewController *zhizhuo = [[MineViewController alloc]initWithName:@"我制作的"];
                zhizhuo.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:zhizhuo animated:YES];
                break;
            }
            case 2:{
               //  NSLog(@"收藏");
                MineViewController *shoucang = [[MineViewController alloc]initWithName:@"我收藏的"];
                shoucang.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shoucang animated:YES];
            }
                break;
            default:
                break;
        }
    }else {
        switch (indexPath.row) {
            case 0:
                 NSLog(@"说明");
                break;
            case 1:
                 NSLog(@"意见");
                break;
            case 2:
                 NSLog(@"免责");
                break;
            case 3: {
                // NSLog(@"缓存");
                
                [self clear];
                
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)clear {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清理缓存" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        
        hud.mode = MBProgressHUDModeText;
        
        hud.margin = 10.f;
        hud.cornerRadius = 20;
        hud.yOffset = kScreenHeight / 3;
        hud.removeFromSuperViewOnHide = YES;
        hud.labelText = @"清理成功";
        [hud show:YES];
        
        [hud hide:YES afterDelay:1];
        
        [self clearCache];
        [self readCacheSize];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 缓存的读取和清理
-(NSUInteger)getCache
{
    NSUInteger size = 0;
    
    //找到缓存路径
    NSString *cache = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    //文件枚举 获取当前路径下所有文件的属性
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:cache];
    
    //拿到文件夹里面的所有文件
    for (NSString *fileName in fileEnumerator) {
        //获取所有文件的路径
        NSString *filePath = [cache stringByAppendingPathComponent:fileName];
        //获取所有文件的属性
        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
        //计算每个文件的大小
        //计算总共文件的大小
        size += [dic fileSize];
    }
    
    return size;
    
}

-(void)readCacheSize
{
    NSUInteger size = [self getCache];
    float MBSize = size / 1024.0 / 1024.0;
    _cacheLabel.text = [NSString stringWithFormat:@"%.1fMB", MBSize];
}

-(void)clearCache
{
    
    //[[SDImageCache sharedImageCache] clearDisk];
    NSString *cache = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [[NSFileManager defaultManager] removeItemAtPath:cache error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:cache
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    
}


#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
