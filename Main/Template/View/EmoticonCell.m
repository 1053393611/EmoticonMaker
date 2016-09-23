//
//  EmoticonCell.m
//  EmoticonMaker
//
//  Created by mac14 on 16/9/13.
//  Copyright © 2016年 mac14. All rights reserved.
//

#import "EmoticonCell.h"

@implementation EmoticonCell

- (void)awakeFromNib {
    
}


-(void)setEmoticon:(EmoticonModel *)emoticon {
    _emoticon = emoticon;
    
    _textLabel.text = _emoticon.name;
    
    if (emoticon.mediaType == 1) {
        [_bgImageView sd_setImageWithURL:[NSURL URLWithString:emoticon.gifPath]];
        _gifImageView.hidden = NO;
    }else {
        [_bgImageView sd_setImageWithURL:[NSURL URLWithString:emoticon.picPath]];
        _gifImageView.hidden = YES;
    }
    
}

@end
