//
//  CameraSizeMaskView.h
//  YKYClient
//
//  Created by tao on 2018/8/4.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraSizeBtn.h"


@interface CameraSizeMaskView : UIView

- (instancetype)initWithFrame:(CGRect)frame rulerTarget:(id)target action:(SEL)action;

//增加动画过渡
- (void)addAnimationFromView:(CameraSizeBtn *)fromView toView:(CameraSizeBtn *)toView;


@end
