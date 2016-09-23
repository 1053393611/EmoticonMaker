//
//  EmoticonCell.h
//  EmoticonMaker
//
//  Created by mac14 on 16/9/13.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface EmoticonCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet CustomLabel *textLabel;


@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;

@property (nonatomic, strong) EmoticonModel *emoticon;

@end
