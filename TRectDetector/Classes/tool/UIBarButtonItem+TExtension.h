//
//  UIBarButtonItem+TExtension.h

//
//  Created by user on 15/10/14.
//  Copyright © 2015年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (TExtension)

+ (UIBarButtonItem *)itemWithTargat:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage;

@end
