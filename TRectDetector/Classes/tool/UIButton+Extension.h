//
//  UIButton+Extension.h
//  efangPlatform
//
//  Created by air on 16/7/28.
//  Copyright © 2016年 air. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)

- (void)title:(NSString *)title titleColor:(NSString *)titleColor backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;



- (void)title:(NSString *)title titleColor:(NSString *)titleColor image:(NSString *)image backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;

- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgHighLighted:(NSString *)imgHighLighted backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;

- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgSelected:(NSString *)imgSelected backgroundColor:(NSString *)backgroundColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;

- (void)title:(NSString *)title titleColor:(NSString *)titleColor imgNormal:(NSString *)imgNormal imgSelected:(NSString *)imgSelected backgroundImage:(NSString *)backgroundImage fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;

- (void)title:(NSString *)title titleColor:(NSString *)titleColor  backgroundImage:(NSString *)backgroundImage fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;

@end
