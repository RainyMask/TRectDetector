//
//  UIBarButtonItem+TExtension.m

//
//  Created by user on 15/10/14.
//  Copyright © 2015年 ZT. All rights reserved.
//

#import "UIBarButtonItem+TExtension.h"
#import "UIImage+TExtension.h"

@implementation UIBarButtonItem (TExtension)

/**
 *  创建一个item
 *
 *  @param target    点击item后调用哪个对象的方法
 *  @param action    点击item后调用target的哪个方法
 *  @param image     图片
 *  @param highImage 高亮的图片
 *
 *  @return 创建完的item
 */
+ (UIBarButtonItem *)itemWithTargat:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    // 设置图片
    [btn setBackgroundImage:[UIImage bundleForImage:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage bundleForImage:highImage] forState:UIControlStateHighlighted];
    
    // 设置尺寸
    CGRect rect = btn.frame;
    rect.size = btn.currentBackgroundImage.size;
    btn.frame = rect;
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
