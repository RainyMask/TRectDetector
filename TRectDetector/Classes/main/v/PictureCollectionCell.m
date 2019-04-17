//
//  PictureCollectionCell.m
//  YKYClient
//
//  Created by tao on 2018/8/14.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "PictureCollectionCell.h"

@interface PictureCollectionCell()<UIScrollViewDelegate>


@end


@implementation PictureCollectionCell


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 3;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.bouncesZoom = YES;

        [self.scrollView addSubview:self.imageView];
        [self addSubview:self.scrollView];

    }
    return self;
}


- (void)layoutSubviews {
    [self.scrollView setZoomScale:1.0f animated:NO];
    self.imageView.frame = self.bounds;
}


#pragma mark --UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.zoomScaleDisable) {
        return nil;
    }
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale <= 1.0) {
        self.imageView.center = scrollView.center;
    }
}


- (void)tapAction {
//    if ([self viewController].presentingViewController) {
//        [[self viewController] dismissViewControllerAnimated:YES completion:nil];
//    }
}



- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}



@end
