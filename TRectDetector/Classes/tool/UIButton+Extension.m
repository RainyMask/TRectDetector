//
//  UIButton+Extension.m
//  efangPlatform
//
//  Created by air on 16/7/28.
//  Copyright © 2016年 air. All rights reserved.
//

#import "UIButton+Extension.h"
#import "UIColor+Hex.h"

@implementation UIButton (Extension)


- (void)title:(NSString *)title titleColor:(NSString *)titleColor backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor: [UIColor colorWithHexString:titleColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.backgroundColor = [UIColor colorWithHexString:backgroundColor];
    
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

}

- (void)title:(NSString *)title titleColor:(NSString *)titleColor image:(NSString *)image backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{
    
    [self title:title titleColor:titleColor backgroundColor:backgroundColor fontSize:fontSize target:target action:action];
    // 图片和显示文字的边距
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
}

- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgHighLighted:(NSString *)imgHighLighted backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{
    
    [self title:title titleColor:titleColor backgroundColor:backgroundColor fontSize:fontSize target:target action:action];
    
    [self setImage:[UIImage imageNamed:imgNormal] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imgHighLighted] forState:UIControlStateHighlighted];
    
}
- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgSelected:(NSString *)imgSelected backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{
    
    [self title:title titleColor:titleColor backgroundColor:backgroundColor fontSize:fontSize target:target action:action];
    
    [self setImage:[UIImage imageNamed:imgNormal] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imgSelected] forState:UIControlStateSelected];
    
}

- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgSelected:(NSString *)imgSelected backgroundImage:(NSString *)backgroundImage fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{

    [self title:title titleColor:titleColor imgNormal:imgNormal imgSelected:imgSelected backgroundColor:nil fontSize:fontSize target:target action:action];
    [self setBackgroundImage:[UIImage imageNamed:backgroundImage] forState:UIControlStateNormal];
}
- (void)title:(NSString *)title titleColor:(NSString *)titleColor backgroundImage:(NSString *)backgroundImage fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action{
    [self title:title titleColor:titleColor backgroundColor:nil fontSize:fontSize target:target action:action];
    [self setBackgroundImage:[UIImage imageNamed:backgroundImage] forState:UIControlStateNormal];
}


@end
