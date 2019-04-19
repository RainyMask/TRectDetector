//
//  TCropViewController.m
//  YKYClient
//
//  Created by tao on 2018/7/30.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TCropViewController.h"
#import "TScannerViewController.h"
#import "TIPDFCalculateManager.h"
#import "GPUImage.h"
#import "TMagnifierView.h"

@interface TCropViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *toolBarView;
@property (nonatomic, strong) UIButton *switchBtn;//中间切换按钮

@property(nonatomic,assign) CGFloat         margin_horizontal;
@property(nonatomic,assign) CGFloat         margin_vertical;
@property(nonatomic,assign) CGRect         contentRect;

@property(nonatomic,strong) CAShapeLayer   *shapeLayer;

@property(nonatomic,strong) IPDFRectangleFeature *rectangleFeature;//始终记录现在展示的坐标
@property(nonatomic,strong) IPDFRectangleFeature *detectionFeature;//检测出来的矩形坐标
@property(nonatomic,strong) IPDFRectangleFeature *edgeFeature;//图片的边界坐标

//四个拖动顶点
@property(nonatomic,strong) UIView    *topLeftVertice;
@property(nonatomic,strong) UIView    *topRightVertice;
@property(nonatomic,strong) UIView    *bottomLeftVertice;
@property(nonatomic,strong) UIView    *bottomRightVertice;
//四个中间点
@property(nonatomic,strong) UIView    *leftMiddleVertice;
@property(nonatomic,strong) UIView    *topMiddleVertice;
@property(nonatomic,strong) UIView    *rightMiddleVertice;
@property(nonatomic,strong) UIView    *bottomMiddleVertice;

/**放大视图*/
@property (nonatomic, strong) TMagnifierView *magnifierView;
@property (nonatomic, strong) UIImageView *contentImageView;

@end

@implementation TCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"智能识边";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#cccccc"];

    //初始配置
    self.margin_horizontal = 20.f;
    self.margin_vertical = 20.f;
    if (iPhoneX) {
        self.contentRect = CGRectMake(self.margin_horizontal, self.margin_vertical, kScreenWidth - 2 * self.margin_horizontal, kScreenHeight - 125 - kIPhoneXBarOffset - kIPhoneXNavHeight - 2 * self.margin_vertical);
    } else {
        self.contentRect = CGRectMake(self.margin_horizontal, self.margin_vertical, kScreenWidth - 2 * self.margin_horizontal, kScreenHeight - 125 - 44 - 2 * self.margin_vertical);
    }
    
    //显示图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentRect];
    imageView.image = self.originalImage;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.contentImageView = imageView;
    
    //显示底部工具条
    [self.view addSubview:self.toolBarView];

    
    //绘制边界遮罩
    [TTool showLoadingInView:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.edgeFeature = [[IPDFRectangleFeature alloc] initWithFeature: [self imageEdgeFeature]];
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.originalImage];
        UIColor *mainColor = [UIImage mainColorOfImage:self.originalImage];
        if (![self isLightColor:mainColor]) {
            ciImage = [[CIImage alloc] initWithImage:[self imageByContrastFilter:self.originalImage]];//暗色图片增加对比度后检测矩形效果更好
        }
        
        CIDetector *detector = [self highAccuracyRectangleDetector];
        NSArray *rectangles = [detector featuresInImage:ciImage options:@{CIDetectorImageOrientation : @(self.originalImage.imageOrientation)}];
        if (rectangles.count == 0) {
            self.rectangleFeature = [[IPDFRectangleFeature alloc] initWithFeature:self.edgeFeature];
            self.switchBtn.selected = NO;
        } else {
            self.detectionFeature = [[IPDFRectangleFeature alloc] initWithFeature:[self coordinateTransformWithCIRectangleFeature:rectangles.firstObject ciImage:ciImage]];
            self.rectangleFeature = [[IPDFRectangleFeature alloc] initWithFeature:self.detectionFeature];
            self.switchBtn.selected = YES;
        }
        [TTool hideInView:self.view];
    });

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//判断颜色是不是亮色
- (BOOL) isLightColor:(UIColor *)color {
    CGFloat components[3];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 bitmapInfo);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
    
    
    
    CGFloat num = components[0] + components[1] + components[2];
    if(num < 250) {
        return NO;
    }
    else {
        return YES;
    }
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:!iPhoneX withAnimation:(UIStatusBarAnimationFade)];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:(UIStatusBarAnimationFade)];
}

- (TMagnifierView *)magnifierView {
    if (!_magnifierView) {
        _magnifierView = [[TMagnifierView alloc] init];
        if (iPhoneX) {
            _magnifierView.center = CGPointMake(self.contentImageView.center.x, self.contentImageView.center.y + kIPhoneXNavHeight);
        } else {
            _magnifierView.center = CGPointMake(self.contentImageView.center.x, self.contentImageView.center.y + kIPhoneXNavHeight - 20);
        }
        _magnifierView.maginfyView = self.contentImageView;
    }
    return _magnifierView;
}

//===============toolBar================VVV
- (UIView *)toolBarView {
    if (!_toolBarView) {
        if (iPhoneX) {
            _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-125-kIPhoneXBarOffset-kIPhoneXNavHeight, kScreenWidth, 125+kIPhoneXBarOffset)];
        } else {
            _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-125-44, kScreenWidth, 125)];
        }
        _toolBarView.backgroundColor = [UIColor whiteColor];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel textColor:@"#000000" textAlignment:(NSTextAlignmentCenter) fontSize:12];
        tipLabel.text = @"可拖动边界以修正文档边缘";
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage bundleForImage:@"camera_cancel"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [switchBtn setImage:[UIImage bundleForImage:@"switch_normal"] forState:UIControlStateNormal];
        [switchBtn setImage:[UIImage bundleForImage:@"switch_sel"] forState:(UIControlStateSelected)];
        [switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.switchBtn = switchBtn;
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setImage:[UIImage bundleForImage:@"camera_confirm"] forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_toolBarView addSubview:tipLabel];
        [_toolBarView addSubview:closeBtn];
        [_toolBarView addSubview:switchBtn];
        [_toolBarView addSubview:confirmBtn];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(_toolBarView);
            make.top.mas_equalTo(_toolBarView.mas_top).offset(20);
            make.height.mas_equalTo(@15);
        }];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(switchBtn);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.centerX.mas_equalTo(_toolBarView.mas_left).offset(kScreenWidth/6.f);
        }];
        [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_toolBarView).offset(-25-kIPhoneXBarOffset);
            make.centerX.mas_equalTo(_toolBarView);
            make.size.mas_equalTo(CGSizeMake(42, 42));
        }];
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(switchBtn);
            make.size.mas_equalTo(closeBtn);
            make.centerX.mas_equalTo(_toolBarView.mas_right).offset(-kScreenWidth/6.f);
        }];
        
        
    }
    return _toolBarView;
}

- (void)closeBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)switchBtnClick:(UIButton *)sender {
    if (self.detectionFeature) {
        self.rectangleFeature  = sender.selected ? [[IPDFRectangleFeature alloc] initWithFeature:self.edgeFeature] : [[IPDFRectangleFeature alloc] initWithFeature: self.detectionFeature];
        sender.selected = !sender.selected;
    } else {
        self.rectangleFeature = [[IPDFRectangleFeature alloc] initWithFeature:self.edgeFeature];
    }
}
- (void)confirmBtnClick:(UIButton *)sender {
 
    [TTool showLoadingInView:self.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage *clipImage = nil;
        if ([self.rectangleFeature.description isEqualToString:self.edgeFeature.description]) {
            clipImage = self.originalImage;//原图
        } else {
            CIImage *ciimage = [[CIImage alloc] initWithImage:self.originalImage];
            CIRectangleFeature *feature = [self coordinateTransformWithIPDFRectangleFeature:self.rectangleFeature ciImage:ciimage];
            clipImage = [self correctPerspectiveForImage:ciimage withFeatures:feature];
        }
        
        if (clipImage == nil) {
            [TTool hideInView:self.view];
            return;
        }
        
        //按照选定尺寸生成图片
        clipImage = [self createTemplateImage:clipImage];
        
        if (self.clipImageBlock) {
            self.clipImageBlock(clipImage);
        }
        
        [TTool hideInView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    });
   
}

#pragma mark ===== 滤镜 ====

- (UIImage *)imageByContrastFilter:(UIImage *)image {
    //对比度 (0 - 4)
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    contrastFilter.contrast = 2.5;
    return [contrastFilter imageByFilteringImage:image];
}

//===============toolBar end===============VVV



//转换为self.view的坐标
- (IPDFRectangleFeature *)coordinateTransformWithCIRectangleFeature:(CIRectangleFeature *)feature ciImage:(CIImage *)ciImage {
    
    CGSize imageSize = ciImage.extent.size;
    CGSize containerSize = self.contentRect.size;

    CGFloat scale = MAX(imageSize.width / containerSize.width, imageSize.height / containerSize.height);

    //scale
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1/scale, 1/scale);
    CGPoint topLeft = CGPointApplyAffineTransform(feature.topLeft, transform);
    CGPoint topRight = CGPointApplyAffineTransform(feature.topRight, transform);
    CGPoint bottomLeft = CGPointApplyAffineTransform(feature.bottomLeft, transform);
    CGPoint bottomRight = CGPointApplyAffineTransform(feature.bottomRight, transform);

    //rotate coordinate-Y + offset
    CGFloat off_x = (containerSize.width - imageSize.width / scale) / 2;
    CGFloat off_y = (containerSize.height - imageSize.height / scale) / 2;

    topLeft = CGPointMake(topLeft.x + off_x, containerSize.height - topLeft.y - off_y);
    topRight = CGPointMake(topRight.x + off_x, containerSize.height - topRight.y - off_y);
    bottomRight = CGPointMake(bottomRight.x + off_x, containerSize.height - bottomRight.y - off_y);
    bottomLeft = CGPointMake(bottomLeft.x + off_x, containerSize.height - bottomLeft.y - off_y);

    //margin
    transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.margin_horizontal, self.margin_vertical);
    topLeft = CGPointApplyAffineTransform(topLeft, transform);
    topRight = CGPointApplyAffineTransform(topRight, transform);
    bottomRight = CGPointApplyAffineTransform(bottomRight, transform);
    bottomLeft = CGPointApplyAffineTransform(bottomLeft, transform);
    
    IPDFRectangleFeature *transformFeature = [[IPDFRectangleFeature alloc] init];
    transformFeature.topLeft = topLeft;
    transformFeature.topRight = topRight;
    transformFeature.bottomLeft = bottomLeft;
    transformFeature.bottomRight = bottomRight;
    
    return transformFeature;
}
//转换为图片的坐标 截取图片
- (CIRectangleFeature *)coordinateTransformWithIPDFRectangleFeature:(IPDFRectangleFeature *)feature ciImage:(CIImage *)ciImage {
    
    CGSize imageSize = ciImage.extent.size;
    CGSize containerSize = self.contentRect.size;
    
    CGFloat scale = MAX(imageSize.width / containerSize.width, imageSize.height / containerSize.height);
    
    //remove margin
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.margin_horizontal, -self.margin_vertical);
    CGPoint topLeft = CGPointApplyAffineTransform(feature.topLeft, transform);
    CGPoint topRight = CGPointApplyAffineTransform(feature.topRight, transform);
    CGPoint bottomRight = CGPointApplyAffineTransform(feature.bottomRight, transform);
    CGPoint bottomLeft = CGPointApplyAffineTransform(feature.bottomLeft, transform);
    
    //rotate coordinate-Y + offset
    CGFloat off_x = (containerSize.width - imageSize.width / scale) / 2;
    CGFloat off_y = (containerSize.height - imageSize.height / scale) / 2;
    
    topLeft = CGPointMake(topLeft.x - off_x, containerSize.height - topLeft.y - off_y);
    topRight = CGPointMake(topRight.x - off_x, containerSize.height - topRight.y - off_y);
    bottomRight = CGPointMake(bottomRight.x - off_x, containerSize.height - bottomRight.y - off_y);
    bottomLeft = CGPointMake(bottomLeft.x - off_x, containerSize.height - bottomLeft.y - off_y);
    
    //scale
    transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    topLeft = CGPointApplyAffineTransform(topLeft, transform);
    topRight = CGPointApplyAffineTransform(topRight, transform);
    bottomLeft = CGPointApplyAffineTransform(bottomLeft, transform);
    bottomRight = CGPointApplyAffineTransform(bottomRight, transform);
    
    IPDFRectangleFeature *transformFeature = [[IPDFRectangleFeature alloc] init];
    transformFeature.topLeft = topLeft;
    transformFeature.topRight = topRight;
    transformFeature.bottomRight = bottomRight;
    transformFeature.bottomLeft = bottomLeft;
    
    return (CIRectangleFeature *)transformFeature;
}
//获取图片的边界
- (IPDFRectangleFeature *)imageEdgeFeature {
    
//    CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.originalImage.size, self.contentRect); //直接获取缩放后的frame

    CGSize imageSize = self.originalImage.size;
    CGSize containerSize = self.contentRect.size;
    
    CGFloat scale = MAX(imageSize.width / containerSize.width, imageSize.height / containerSize.height);
    
    CGFloat width = imageSize.width / scale;
    CGFloat height = imageSize.height / scale;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.contentRect), CGRectGetMidY(self.contentRect));

    IPDFRectangleFeature *imageFeature = [[IPDFRectangleFeature alloc] init];
    imageFeature.topLeft = CGPointMake(center.x - width / 2, center.y - height / 2);
    imageFeature.topRight = CGPointMake(center.x + width / 2, center.y - height / 2);
    imageFeature.bottomLeft = CGPointMake(center.x - width / 2, center.y + height / 2);
    imageFeature.bottomRight = CGPointMake(center.x + width / 2, center.y + height / 2);
    
    return imageFeature;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.view.bounds;
        _shapeLayer.fillColor = [UIColor colorWithHexString:MAIN_COLOR_S alpha:0.3].CGColor;
        _shapeLayer.strokeColor = MAIN_COLOR.CGColor;
        _shapeLayer.lineWidth = 2;
    }
    return _shapeLayer;
}

- (void)setRectangleFeature:(IPDFRectangleFeature *)rectangleFeature {
    _rectangleFeature = rectangleFeature;
    
    [self drawOverLayer];
    
    [self addVertices];
}


//检测器
- (CIDetector *)highAccuracyRectangleDetector {
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                      context:nil
                                      options:@{
                                                CIDetectorAccuracy : CIDetectorAccuracyHigh,
                                                CIDetectorImageOrientation:@(0),
                                                }];
    });
    return detector;
}

-(void)drawOverLayer {
    
    self.shapeLayer.path = nil;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.rectangleFeature.topLeft];
    [path addLineToPoint:self.rectangleFeature.topRight];
    [path addLineToPoint:self.rectangleFeature.bottomRight];
    [path addLineToPoint:self.rectangleFeature.bottomLeft];
    [path addLineToPoint:self.rectangleFeature.topLeft];
    
    self.shapeLayer.path = path.CGPath;
    
    if (!self.shapeLayer.superlayer) {
        [self.view.layer addSublayer:self.shapeLayer];
    }
}

//设置可拖动顶点
- (void)addVertices {
    
    //顶点
    if (!self.topLeftVertice) {
        self.topLeftVertice = [self creatVerticeWithAction:@selector(topLeftPanAction:)];
    }
    self.topLeftVertice.center = self.rectangleFeature.topLeft;

    
    if (!self.topRightVertice) {
        self.topRightVertice = [self creatVerticeWithAction:@selector(topRightPanAction:)];
    }
    self.topRightVertice.center = self.rectangleFeature.topRight;

    
    if (!self.bottomLeftVertice) {
        self.bottomLeftVertice = [self creatVerticeWithAction:@selector(bottomLeftPanAction:)];
    }
    self.bottomLeftVertice.center = self.rectangleFeature.bottomLeft;

    if (!self.bottomRightVertice) {
        self.bottomRightVertice = [self creatVerticeWithAction:@selector(bottomRightPanAction:)];
    }
    self.bottomRightVertice.center = self.rectangleFeature.bottomRight;
    
    
    
    //边线中点
    if (!self.leftMiddleVertice) {
        self.leftMiddleVertice = [self creatVerticeWithAction:@selector(leftMiddlePanAction:)];
    }
    self.leftMiddleVertice.center = self.rectangleFeature.leftMiddle;
    
    
    if (!self.topMiddleVertice) {
        self.topMiddleVertice = [self creatVerticeWithAction:@selector(topMiddlePanAction:)];
    }
    self.topMiddleVertice.center = self.rectangleFeature.topMiddle;
    
    
    if (!self.rightMiddleVertice) {
        self.rightMiddleVertice = [self creatVerticeWithAction:@selector(rightMiddlePanAction:)];
    }
    self.rightMiddleVertice.center = self.rectangleFeature.rightMiddle;
    
    
    if (!self.bottomMiddleVertice) {
        self.bottomMiddleVertice = [self creatVerticeWithAction:@selector(bottomMiddlePanAction:)];
    }
    self.bottomMiddleVertice.center = self.rectangleFeature.bottomMiddle;
}

- (UIImageView *)creatVerticeWithAction:(SEL)action {
    UIImageView *vertice = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    vertice.image = [UIImage bundleForImage:@"vertices"];
    vertice.contentMode = UIViewContentModeCenter;
    vertice.userInteractionEnabled = YES;
    [self.view addSubview:vertice];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:action];
    pan.delegate = self;
    [vertice addGestureRecognizer:pan];
    
    return vertice;
}

//顶点
- (void)topLeftPanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetVertice:self.topLeftVertice  sender:sender];
}

- (void)topRightPanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetVertice:self.topRightVertice  sender:sender];
}

- (void)bottomLeftPanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetVertice:self.bottomLeftVertice  sender:sender];
}

- (void)bottomRightPanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetVertice:self.bottomRightVertice  sender:sender];
}

//边线中点
- (void)leftMiddlePanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetMiddleVertice:self.leftMiddleVertice  sender:sender];
}

- (void)topMiddlePanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetMiddleVertice:self.topMiddleVertice  sender:sender];
}

- (void)rightMiddlePanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetMiddleVertice:self.rightMiddleVertice  sender:sender];
}

- (void)bottomMiddlePanAction:(UIPanGestureRecognizer *)sender {
    [self changeTargetMiddleVertice:self.bottomMiddleVertice  sender:sender];
}


- (void)changeTargetVertice:(UIView *)targetVertice sender:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.magnifierView.maginfyPoint = [sender locationInView:self.contentImageView];
        [self.magnifierView makeKeyAndVisible];

    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        //临时存放四个顶点的值
        CGPoint temp_TL = self.rectangleFeature.topLeft;
        CGPoint temp_TR = self.rectangleFeature.topRight;
        CGPoint temp_BL = self.rectangleFeature.bottomLeft;
        CGPoint temp_BR = self.rectangleFeature.bottomRight;
        
        
        CGPoint location = [sender locationInView:self.view];
        //边界处理
        location = [self correctPointInEdge:location];
        
        
        if ([targetVertice isEqual:self.topLeftVertice]) {
            temp_TL = location;
            if (![TIPDFCalculateManager isQuadrilateralOfPoints:temp_TL topR:temp_TR bottomL:temp_BL bottomR:temp_BR] ||
                [TIPDFCalculateManager distanceOfStartPoint:location toEndPoint:temp_BR] < 25) { //最远的顶点不重合
                return;
            }
            self.rectangleFeature.topLeft = location;
            self.magnifierView.maginfyPoint = [self.contentImageView convertPoint:location fromView:self.view];
        }
        else if ([targetVertice isEqual:self.topRightVertice]) {
            temp_TR = location;
            if (![TIPDFCalculateManager isQuadrilateralOfPoints:temp_TL topR:temp_TR bottomL:temp_BL bottomR:temp_BR] ||
                [TIPDFCalculateManager distanceOfStartPoint:location toEndPoint:temp_BL] < 25) {
                return;
            }
            self.rectangleFeature.topRight = location;
            self.magnifierView.maginfyPoint = [self.contentImageView convertPoint:location fromView:self.view];
        }
        else if ([targetVertice isEqual:self.bottomLeftVertice]) {
            temp_BL = location;
            if (![TIPDFCalculateManager isQuadrilateralOfPoints:temp_TL topR:temp_TR bottomL:temp_BL bottomR:temp_BR] ||
                [TIPDFCalculateManager distanceOfStartPoint:location toEndPoint:temp_TR] < 25) {
                return;
            }
            self.rectangleFeature.bottomLeft = location;
            self.magnifierView.maginfyPoint = [self.contentImageView convertPoint:location fromView:self.view];
        }
        else if ([targetVertice isEqual:self.bottomRightVertice]) {
            temp_BR = location;
            if (![TIPDFCalculateManager isQuadrilateralOfPoints:temp_TL topR:temp_TR bottomL:temp_BL bottomR:temp_BR] ||
                [TIPDFCalculateManager distanceOfStartPoint:location toEndPoint:temp_TL] < 25) {
                return;
            }
            self.rectangleFeature.bottomRight = location;
            self.magnifierView.maginfyPoint = [self.contentImageView convertPoint:location fromView:self.view];
        }
        
        
        [self drawOverLayer];
        [self addVertices];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierView.alpha = 0;
        } completion:^(BOOL finished) {
            self.magnifierView.hidden = YES;
            self.magnifierView.alpha = 1;
        }];
    }
}


- (void)changeTargetMiddleVertice:(UIView *)targetVertice sender:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        //临时存放四个顶点的值
        CGPoint temp_TL = self.rectangleFeature.topLeft;
        CGPoint temp_TR = self.rectangleFeature.topRight;
        CGPoint temp_BL = self.rectangleFeature.bottomLeft;
        CGPoint temp_BR = self.rectangleFeature.bottomRight;
        //临时存放中点点的值
        CGPoint temp_LM = self.rectangleFeature.leftMiddle;
        CGPoint temp_TM = self.rectangleFeature.topMiddle;
        CGPoint temp_RM = self.rectangleFeature.rightMiddle;
        CGPoint temp_BM = self.rectangleFeature.bottomMiddle;
        
        
        CGPoint location = [sender locationInView:self.view];
        
        if ([targetVertice isEqual:self.leftMiddleVertice]) {
            temp_TL = [self pointTranslationLocation:location referencePoint:temp_LM targetPoint:temp_TL];
            temp_BL = [self pointTranslationLocation:location referencePoint:temp_LM targetPoint:temp_BL];
        }
        else if ([targetVertice isEqual:self.topMiddleVertice]) {
            temp_TL = [self pointTranslationLocation:location referencePoint:temp_TM targetPoint:temp_TL];
            temp_TR = [self pointTranslationLocation:location referencePoint:temp_TM targetPoint:temp_TR];
        }
        else if ([targetVertice isEqual:self.rightMiddleVertice]) {
            temp_TR = [self pointTranslationLocation:location referencePoint:temp_RM targetPoint:temp_TR];
            temp_BR = [self pointTranslationLocation:location referencePoint:temp_RM targetPoint:temp_BR];
        }
        else if ([targetVertice isEqual:self.bottomMiddleVertice]) {
            temp_BL = [self pointTranslationLocation:location referencePoint:temp_BM targetPoint:temp_BL];
            temp_BR = [self pointTranslationLocation:location referencePoint:temp_BM targetPoint:temp_BR];
        }
        
        //与最远顶点保持距离
        if ([TIPDFCalculateManager distanceOfStartPoint:temp_BR toEndPoint:temp_TL] < 25 ||
            [TIPDFCalculateManager distanceOfStartPoint:temp_TR toEndPoint:temp_BL] < 25 ) {
            return;
        }
        
        //边界处理
//        temp_TL = [self correctPointInEdge:temp_TL];
//        temp_TR = [self correctPointInEdge:temp_TR];
//        temp_BR = [self correctPointInEdge:temp_BR];
//        temp_BL = [self correctPointInEdge:temp_BL];
        
        //边界判断
        if ([self isArriveEdge:temp_TL] || [self isArriveEdge:temp_TR] || [self isArriveEdge:temp_BR] || [self isArriveEdge:temp_BL]) {
            return;
        }
        

        //四边形判断
        if (![TIPDFCalculateManager isQuadrilateralOfPoints:temp_TL topR:temp_TR bottomL:temp_BL bottomR:temp_BR]) {
            return;
        }
        
        
        self.rectangleFeature.topLeft = temp_TL;
        self.rectangleFeature.topRight = temp_TR;
        self.rectangleFeature.bottomRight = temp_BR;
        self.rectangleFeature.bottomLeft = temp_BL;
        
        [self drawOverLayer];
        [self addVertices];
        
    }
}

//坐标边界处理
- (CGPoint)correctPointInEdge:(CGPoint)point {
    
    if (point.y < self.edgeFeature.topLeft.y) {
        point.y = self.edgeFeature.topLeft.y;
    }
    else if (point.y > self.edgeFeature.bottomRight.y) {
        point.y = self.edgeFeature.bottomRight.y;
    }
    
    
    if (point.x < self.edgeFeature.topLeft.x) {
        point.x = self.edgeFeature.topLeft.x;
    }
    else if (point.x > self.edgeFeature.bottomRight.x) {
        point.x = self.edgeFeature.bottomRight.x;
    }
    
    return point;
}

//坐标触及边界判断
- (BOOL)isArriveEdge:(CGPoint)point {
    if (point.y < self.edgeFeature.topLeft.y || point.y > self.edgeFeature.bottomRight.y || point.x < self.edgeFeature.topLeft.x || point.x > self.edgeFeature.bottomRight.x) {
        return YES;
    }
    return NO;
}



//坐标平移
- (CGPoint)pointTranslationLocation:(CGPoint)location referencePoint:(CGPoint)referencePonit targetPoint:(CGPoint)targetPoint {
    CGFloat offx = location.x - referencePonit.x;
    CGFloat offy = location.y - referencePonit.y;
    
    if (fabs(offx) < 15 && fabs(offy) > 15) { //添加10pt容错操作
        offx = 0;
    }
    
    if (fabs(offy) < 15 && fabs(offx) > 15) {
        offy = 0;
    }
    
    return CGPointApplyAffineTransform(targetPoint, CGAffineTransformMakeTranslation(offx, offy));
}



//截取矩形框内的图片并返回
- (UIImage *)correctPerspectiveForImage:(CIImage *)ciimage withFeatures:(CIRectangleFeature *)rectangleFeature {
    //矩形矫正
    NSMutableDictionary *rectangleCoordinates = [[NSMutableDictionary alloc] initWithCapacity:4];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    ciimage = [ciimage imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];

    static CIContext *ctx = nil;
    if (!ctx) {
        ctx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
    }

    CGImageRef imageRef = [ctx createCGImage:ciimage fromRect:ciimage.extent];
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return returnImage;
    
}



//尺寸模式 绘制带白底的图片
- (UIImage *)createTemplateImage:(UIImage *)image {
    
    CGSize imageSize = CGSizeZero;
    if (self.sizeType) {
        NSLog(@"======> 尺寸模式 %ld ", self.sizeType);
        
        CGFloat pixelScale = 1;
        
//        A4像素：595x842(210x297mm)   16开像素：524x737(185x260mm)  A6像素：298x420(105x148mm)
        UIView *whiteBachView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 595 * pixelScale, 842 * pixelScale)];
        whiteBachView.backgroundColor = [UIColor whiteColor];
        
        if (self.sizeType == 1) {
            imageSize = whiteBachView.bounds.size;
        }
        else if (self.sizeType == 2) {
            imageSize = CGSizeMake(whiteBachView.bounds.size.width * 524 / 595, whiteBachView.bounds.size.height * 737 / 842);
        }
        else if (self.sizeType == 3) {
            imageSize = CGSizeMake(whiteBachView.bounds.size.width * 298 / 595, whiteBachView.bounds.size.height * 420 / 842);
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        imageView.center = whiteBachView.center;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        
        [whiteBachView addSubview:imageView];
        
        
        UIGraphicsBeginImageContextWithOptions(whiteBachView.bounds.size, YES, [UIScreen mainScreen].scale);
        [whiteBachView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return tempImage;
        
    } else {
        return image;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
