//
//  UILabel+Extension.h
//  efangPlatform
//
//  Created by air on 16/7/28.
//  Copyright © 2016年 air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Extension)


- (void)textColor:(NSString *)textColor fontSize:(CGFloat)fontSize;
- (void)textColor:(NSString *)textColor textAlignment:(NSTextAlignment)textAlignment fontSize:(CGFloat)fontSize;

- (void)text:(NSString *)text textColor:(NSString *)textColor fontSize:(CGFloat)fontSize;


/**
 *  改变行间距
 */
- (void)changeLineSpaceWithSpace:(float)space;

/**
 *  改变字间距
 */
- (void)changeWordSpaceWithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace;


@end
