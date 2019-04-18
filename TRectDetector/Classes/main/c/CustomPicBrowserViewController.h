//
//  CustomPicBrowserViewController.h
//  YKYClient
//
//  Created by tao on 2018/8/14.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "BaseViewController.h"
#import "Header.h"

@interface CustomPicBrowserViewController : BaseViewController

@property (nonatomic, strong) NSArray *imagesArr;

- (void)setImagesArr:(NSArray *)imagesArr atIndex:(NSInteger)index;


@end
