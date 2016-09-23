//
//  PersonCell.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/14.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "PersonCell.h"

@implementation PersonCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)setEmoticon:(EmoticonModel *)emoticon {
    _emoticon = emoticon;
    
    _textLabel.text = emoticon.name;

    [_imageView sd_setImageWithURL:[NSURL URLWithString:emoticon.picPath]];
        
    
    
}

@end
