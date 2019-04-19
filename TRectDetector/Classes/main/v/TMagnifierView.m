//
//  TMagnifierView.m
//  YKYClient
//
//  Created by tao on 2018/9/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TMagnifierView.h"

@interface TMagnifierView()
@property (nonatomic, strong) CALayer *contentLayer;

@end


@implementation TMagnifierView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 80, 80);
        self.windowLevel = UIWindowLevelAlert;
        
        kBorder(self, 2, [UIColor whiteColor]);
        kRoundCorner(self, 4);
        
        [self.layer addSublayer:self.contentLayer];
    
        UIView *transverseLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 80, 1)];
        transverseLine.backgroundColor = MAIN_COLOR;
        
        UIView *longitudinalLine = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 1, 80)];
        longitudinalLine.backgroundColor = MAIN_COLOR;
        
        [self addSubview:transverseLine];
        [self addSubview:longitudinalLine];
    }
    return self;
    
}

- (CALayer *)contentLayer {
    if (!_contentLayer) {
        _contentLayer  = [CALayer layer];
        _contentLayer.frame = self.bounds;
        _contentLayer.delegate = self;
        _contentLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _contentLayer;
}

- (void)setMaginfyPoint:(CGPoint)maginfyPoint {
    _maginfyPoint = maginfyPoint;
    [self.contentLayer setNeedsDisplay];
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    CGContextTranslateCTM(ctx, 0, 0);
    CGContextScaleCTM(ctx, 2, 2);
    CGContextTranslateCTM(ctx, - self.maginfyPoint.x + 20, - self.maginfyPoint.y + 20);
    [self.maginfyView.layer renderInContext:ctx];
}








@end
