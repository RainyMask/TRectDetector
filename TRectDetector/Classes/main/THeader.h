//
//  THeader.h
//  Pods
//
//  Created by tao on 2019/4/19.
//

#ifndef THeader_h
#define THeader_h


#endif /* THeader_h */


#import "UIBarButtonItem+TExtension.h"
#import "TBaseViewController.h"
#import "TBaseNavViewController.h"
#import "UIColor+THex.h"
#import "UILabel+TExtension.h"
#import "UIButton+TExtension.h"
#import "UIImage+TExtension.h"
#import "TTool.h"
#import "Masonry.h"



//theme
#define MAIN_COLOR_S        @"#18b8f4"
#define MAIN_COLOR          [UIColor colorWithHexString:MAIN_COLOR_S]


//nav
#define NAV_TITLE_FONT       17
#define NAV_TITLE_COLOR      @"#080808"
#define NAV_ITEM_FONT        16
#define NAV_ITEM_COLOR       @"#080808"



//nslog
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"<%s(%d)>\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(FORMAT, ...) nil
#endif

#define kWeakSelf(weakSelf)  __weak typeof(self)weakSelf = self;
#define kRoundCorner(view,radius) view.layer.cornerRadius = radius;view.layer.masksToBounds = YES;
#define kBorder(view,width,color) view.layer.borderWidth = width;view.layer.borderColor = color.CGColor;


#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]


#define iOS11 @available(iOS 11.0, *)


#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)


#define kIPhoneXBarHeight        (iPhoneX ? 83.0f : 49.0f)
#define kIPhoneXBarOffset        (iPhoneX ? 34.0f : 0)
#define kIPhoneXNavHeight        (iPhoneX ? 88.0f : 64.0f)
#define kIPhoneXNavOffset        (iPhoneX ? 24.0f : 0)
