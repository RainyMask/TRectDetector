//
//  CameraSizeMaskView.m
//  YKYClient
//
//  Created by tao on 2018/8/4.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "CameraSizeMaskView.h"

@interface CameraSizeMaskView ()

@property (nonatomic, strong) UILabel *leftLablel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIView *boundary;
@property (nonatomic, strong) UIButton *ruler;

@property (nonatomic, strong) UIView *transitionView;


@end


@implementation CameraSizeMaskView {
    BOOL _isDraw;
}

- (instancetype)initWithFrame:(CGRect)frame rulerTarget:(id)target action:(SEL)action {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        CGRect retangleFrame = [self retangeleFrame:frame];;
        
        //添加白色边线
        self.boundary = [[UIView alloc] initWithFrame:retangleFrame];
        kBorder(_boundary, 2, [UIColor whiteColor]);
        [self addSubview:_boundary];
        
        //添加尺寸描述
        self.leftLablel = [[UILabel alloc] init];
        [_leftLablel textColor:@"#ffffff" textAlignment:(NSTextAlignmentLeft) fontSize:11];
        self.rightLabel = [[UILabel alloc] init];
        [_rightLabel textColor:@"#ffffff" textAlignment:(NSTextAlignmentRight) fontSize:11];
        
        [self addSubview:_leftLablel];
        [self addSubview:_rightLabel];
        
        [_leftLablel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_boundary).offset(5);
            make.top.mas_equalTo(_boundary).offset(8);
        }];
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_boundary).offset(-5);
            make.top.mas_equalTo(_leftLablel);
        }];
        
        //尺子按钮
        self.ruler = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ruler setBackgroundImage:[UIImage imageNamed:@"size_ruler"] forState:UIControlStateNormal];
        [_ruler setBackgroundImage:[UIImage imageNamed:@"size_ruler"] forState:UIControlStateHighlighted];
        [_ruler addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_ruler];
        
        [_ruler mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(_boundary);
        }];
        
        //过渡动画
        self.transitionView = [[UIView alloc] initWithFrame:CGRectZero];
        kBorder(self.transitionView, 2, [UIColor colorWithHexString:@"#888888"]);
        self.transitionView.hidden = YES;
        [self addSubview:self.transitionView];
    }
    return self;
}

- (void)addAnimationFromView:(CameraSizeBtn *)fromView toView:(CameraSizeBtn *)toView {
    self.hidden = NO;

    [self setAnimationInitalStateWithView:fromView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transitionView.center = toView.center;
        self.transitionView.bounds = toView.bounds;
    } completion:^(BOOL finished) {
        [self setAnimationCompleteStateWithView:fromView];
    }];
}

//设置动画初始状态
- (void)setAnimationInitalStateWithView:(CameraSizeBtn *)view {
    self.leftLablel.text = @"";
    self.rightLabel.text = @"";
    
    self.boundary.layer.borderColor = [UIColor colorWithHexString:@"#888888"].CGColor;
    self.ruler.hidden = YES;
    
    self.transitionView.frame = view.frame;
    self.transitionView.hidden = NO;
}

//设置动画结束状态
- (void)setAnimationCompleteStateWithView:(CameraSizeBtn *)view {
    self.leftLablel.text = view.leftTitle;
    self.rightLabel.text = view.rightTitle;
    
    self.boundary.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ruler.hidden = NO;
    
    self.transitionView.hidden = YES;
}



- (void)drawRect:(CGRect)rect {
    if (_isDraw) {
        return;
    }
    
    CGRect retangleFrame = [self retangeleFrame:rect];;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];//背景
    UIBezierPath *retangle = [UIBezierPath bezierPathWithRect:retangleFrame];//镂空区域
    
    [path appendPath:retangle];
    
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.opacity = 0.3;
    
    [self.layer addSublayer:layer];
    
    _isDraw = YES;
}

- (CGRect)retangeleFrame:(CGRect)rect {
    CGFloat margin;
    if (iPhoneX) {
        margin = 20;
    } else {
        margin = 35;
    }
    if (kScreenHeight == 480) {
        margin = 65;
    }
   
    CGFloat W_A4 = rect.size.width - margin * 2;
    CGFloat H_A4 = W_A4 * 842 / 595;
    CGRect retangleFrame = CGRectMake(margin, (rect.size.height - H_A4)/2, W_A4, H_A4);
    return retangleFrame;
}

@end
