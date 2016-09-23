//
//  PersonCell.h
//  EmoticonMaker
//
//  Created by mac14 on 16/9/14.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic, strong) EmoticonModel *emoticon;
@end
