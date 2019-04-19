//
//  TCropViewController.h
//  YKYClient
//
//  Created by tao on 2018/7/30.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TBaseViewController.h"

@interface TCropViewController : TBaseViewController

@property (nonatomic, strong) UIImage *originalImage;

/** 1 - A4  2 - 16K  3 - A6*/
@property (nonatomic, assign) NSInteger sizeType;

/**
 裁剪图片后回调
 */
@property (nonatomic, copy) void(^clipImageBlock)(UIImage *image);

@end
