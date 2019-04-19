//
//  TPictureCollectionCell.h
//  YKYClient
//
//  Created by tao on 2018/8/14.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPictureCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;


@property (nonatomic, assign) BOOL zoomScaleDisable;

@end
