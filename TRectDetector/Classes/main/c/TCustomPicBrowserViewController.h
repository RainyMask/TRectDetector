//
//  TCustomPicBrowserViewController.h
//  YKYClient
//
//  Created by tao on 2018/8/14.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TBaseViewController.h"
#import "THeader.h"

@interface TCustomPicBrowserViewController : TBaseViewController

@property (nonatomic, strong) NSArray *imagesArr;

- (void)setImagesArr:(NSArray *)imagesArr atIndex:(NSInteger)index;


@end
