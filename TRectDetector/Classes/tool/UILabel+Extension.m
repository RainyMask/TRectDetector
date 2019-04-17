//
//  UILabel+Extension.m
//  efangPlatform
//
//  Created by air on 16/7/28.
//  Copyright © 2016年 air. All rights reserved.
//

#import "UILabel+Extension.h"
#import "UIColor+Hex.h"

@implementation UILabel (Extension)

- (void)textColor:(NSString *)textColor fontSize:(CGFloat)fontSize{
    self.font = [UIFont systemFontOfSize:fontSize];
    self.textColor = [UIColor colorWithHexString:textColor];
    
}
- (void)textColor:(NSString *)textColor textAlignment:(NSTextAlignment)textAlignment fontSize:(CGFloat)fontSize{
    [self textColor:textColor fontSize:fontSize];
    self.textAlignment = textAlignment;
}
- (void)text:(NSString *)text textColor:(NSString *)textColor fontSize:(CGFloat)fontSize{
    [self textColor:textColor fontSize:fontSize];
    self.text = text;
}


- (void)changeLineSpaceWithSpace:(float)space {
    if (self.text.length == 0) {
        return;
    }
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

- (void)changeWordSpaceWithSpace:(float)space {
    if (self.text.length == 0) {
        return;
    }
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}
- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace {
    if (self.text.length == 0) {
        return;
    }
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

@end
