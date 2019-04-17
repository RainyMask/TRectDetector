//
//  MagnifierView.h
//  YKYClient
//
//  Created by tao on 2018/9/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIWindow

/** 要放大的视图*/
@property (nonatomic, strong) UIView *maginfyView;
/** 要放大的点*/
@property (nonatomic, assign) CGPoint maginfyPoint;

@end
