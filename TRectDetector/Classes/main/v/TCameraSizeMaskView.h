//
//  TCameraSizeMaskView.h
//  YKYClient
//
//  Created by tao on 2018/8/4.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCameraSizeBtn.h"


@interface TCameraSizeMaskView : UIView

- (instancetype)initWithFrame:(CGRect)frame rulerTarget:(id)target action:(SEL)action;

//增加动画过渡
- (void)addAnimationFromView:(TCameraSizeBtn *)fromView toView:(TCameraSizeBtn *)toView;


@end
