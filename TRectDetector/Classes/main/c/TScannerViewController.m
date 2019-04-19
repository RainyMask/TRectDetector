//
//  TScannerViewController.m
//  YKYClient
//
//  Created by tao on 2018/7/24.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <GLKit/GLKit.h>
#import "GPUImage.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"

#import "TCropViewController.h"
#import "TCameraSizeBtn.h"
#import "TCameraSizeMaskView.h"
#import "TCustomPicBrowserViewController.h"
#import "TScannerCamera.h"
#import "TIPDFCalculateManager.h"


@implementation IPDFRectangleFeature

- (instancetype)initWithFeature:(IPDFRectangleFeature *)feature {
    if (self = [super init]) {
        self.topLeft = feature.topLeft;
        self.topRight = feature.topRight;
        self.bottomLeft = feature.bottomLeft;
        self.bottomRight = feature.bottomRight;
    }
    return self;
}

- (CGPoint)leftMiddle {
    return CGPointMake((_topLeft.x + _bottomLeft.x) / 2, (_topLeft.y + _bottomLeft.y) / 2);
}

- (CGPoint)topMiddle {
    return CGPointMake((_topLeft.x + _topRight.x) / 2, (_topLeft.y + _topRight.y) /2);
}

-(CGPoint)rightMiddle {
    return CGPointMake((_topRight.x + _bottomRight.x) /2, (_topRight.y + _bottomRight.y) /2);
}

- (CGPoint)bottomMiddle {
    return CGPointMake((_bottomLeft.x + _bottomRight.x) / 2, (_bottomLeft.y + _bottomRight.y) / 2);
}

- (NSString *)description {
    return  [NSString stringWithFormat:@"%@%@%@%@",
             NSStringFromCGPoint(self.topLeft),
             NSStringFromCGPoint(self.topRight),
             NSStringFromCGPoint(self.bottomLeft),
             NSStringFromCGPoint(self.bottomRight)];
}

@end


@interface TScannerViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, TZImagePickerControllerDelegate>

@property (nonatomic,assign) BOOL enableBorderDetection;//默认YES

@property (nonatomic,strong) UIImageView *focusIndicator;

@property (nonatomic,strong) UIView *toolBarView;
@property (nonatomic,strong) UIButton *defaultBtn;
@property (nonatomic,strong) UIButton *sizeBtn;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIButton *confirmBtn;

@property (nonatomic,strong) UIImageView *gridImageView;//默认
@property (nonatomic,strong) UIImageView *sizeImageView;//尺寸模式     start v
@property (nonatomic,strong) UIView *btnView;
@property (nonatomic,strong) TCameraSizeBtn *btn_A4;
@property (nonatomic,strong) TCameraSizeBtn *btn_16K;
@property (nonatomic,strong) TCameraSizeBtn *btn_A6;
@property (nonatomic,strong) TCameraSizeMaskView *maskView;//尺寸模式    end ^
/** 1 - A4  2 - 16K  3 - A6*/
@property (nonatomic, assign) NSInteger sizeType;

@property (nonatomic,strong) CIRectangleFeature    *borderDetectLastRectangleFeature;
@property (nonatomic,strong) IPDFRectangleFeature   *realRectangleFeature; //处理后的矩形坐标
@property (nonatomic,strong) NSTimer *borderDetectTimeKeeper;

@property (nonatomic,assign) CGRect contentRect;//容器尺寸
@property (nonatomic,assign) CGSize contentSize;//容器尺寸
@property (nonatomic,assign) CGRect visibleRect;//实际观测区域

@property (nonatomic, strong) UILabel *numberLabel;//显示图片个数

@property (nonatomic, strong) TZImagePickerController *imagePickerController;

@property (nonatomic, assign) CGFloat lastRectangleArea;//上一个矩形的面积

@end

@implementation TScannerViewController {
    BOOL _isStopped;//停止
    BOOL _isCapturing;//正在拍照
    CGFloat _imageDedectionConfidence;
    CGFloat _errorDedectionConfidence;
    dispatch_queue_t _captureQueue;
}

@synthesize resultImageArr = _resultImageArr;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描拍照";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTargat:self action:@selector(closeClick) image:@"camera_close" highImage:@"camera_close"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foregroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
    _captureQueue = dispatch_get_main_queue();
    self.enableBorderDetection = YES;
    
    
    if (iPhoneX) {
        self.visibleRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 125 - kIPhoneXBarOffset - kIPhoneXNavHeight);
    } else {
        self.visibleRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 125 - 44);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initCameraConfig];
    });
}

- (TZImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        _imagePickerController.sortAscendingByModificationDate = NO;
        _imagePickerController.allowPickingVideo = NO;
        _imagePickerController.allowPickingGif = NO;
        _imagePickerController.allowTakePicture = NO;
        _imagePickerController.autoDismiss = NO;
        _imagePickerController.naviBgColor = [UIColor whiteColor];
        _imagePickerController.naviTitleColor = [UIColor colorWithHexString:NAV_TITLE_COLOR];
        _imagePickerController.naviTitleFont = [UIFont systemFontOfSize:NAV_TITLE_FONT];
        _imagePickerController.barItemTextFont = [UIFont systemFontOfSize:NAV_ITEM_FONT];
        _imagePickerController.barItemTextColor = [UIColor colorWithHexString:NAV_ITEM_COLOR];
        _imagePickerController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
        _imagePickerController.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
            [leftButton setImage:[UIImage bundleForImage:@"back"] forState:UIControlStateNormal];
            [leftButton setTitle:@"返回" forState:UIControlStateNormal];
            [leftButton setTitleColor:[UIColor colorWithHexString:NAV_ITEM_COLOR] forState:UIControlStateNormal];
            [leftButton.titleLabel setFont:[UIFont systemFontOfSize:NAV_ITEM_FONT]];
        };
        
    }
    return _imagePickerController;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.toolBarView.hidden = NO;
    [self start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.toolBarView.hidden = YES;
    [self stop];
}
- (void)_foregroundMode {
    [self start];
}

- (void)_backgroundMode {
    [self stop];
    if ([TScannerCamera sharedInstance].captureDevice) {
        [[TScannerCamera sharedInstance].captureSession stopRunning];
    }
}

// 开始
- (void)start {
    if ([TScannerCamera sharedInstance].captureDevice) {
        _isStopped = NO;
        
        _imageDedectionConfidence = 0.0;
        _errorDedectionConfidence = 0.0;
        [[TScannerCamera sharedInstance].overLayer removeFromSuperlayer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(openenBorderDetectFunction) userInfo:nil repeats:YES];
            [[TScannerCamera sharedInstance].captureSession startRunning];
            [self focusAtPoint:CGPointMake(CGRectGetMidX(self.visibleRect), CGRectGetMidY(self.visibleRect))];
        });
    }
}
//停止
- (void)stop {
    if ([TScannerCamera sharedInstance].captureDevice) {
        _isStopped = YES;
        [[TScannerCamera sharedInstance].overLayer removeFromSuperlayer];
    
        [self.borderDetectTimeKeeper invalidate];
        self.borderDetectTimeKeeper = nil;
    }
}

- (void)openenBorderDetectFunction {
    self.enableBorderDetection = YES;
}


- (void)closeClick {
    if (self.resultImageArr.count > 0) {
        NSString *message = [NSString stringWithFormat:@"您已经拍摄%ld张照片，现在退出的话，拍摄的照片将会被清除，您确定退出吗？",self.resultImageArr.count];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancel];
        [alertVC addAction:confirm];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark ---- 记录图片相关 ---
- (NSMutableArray *)resultImageArr {
    if (!_resultImageArr) {
        _resultImageArr = [NSMutableArray arrayWithCapacity:3];
    }
    return _resultImageArr;
}

- (void)setResultImageArr:(NSMutableArray *)resultImageArr {
    _resultImageArr = resultImageArr;
}

- (void)addNewResultImage:(UIImage *)image {
    [self.resultImageArr addObject:image];
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",self.resultImageArr.count];
    self.numberLabel.hidden = NO;
    self.confirmBtn.enabled = YES;
}



//===============toolBar================VVV
- (UIView *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-125-kIPhoneXBarOffset, kScreenWidth, 125+kIPhoneXBarOffset)];
        _toolBarView.backgroundColor = [UIColor whiteColor];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel textColor:@"#ffffff" textAlignment:(NSTextAlignmentCenter) fontSize:12];
        tipLabel.text = @"拍照时请保持文档在框内";
        self.tipLabel = tipLabel;
        
        UIButton *defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [defaultBtn title:@"默认" titleColor:@"#888888" backgroundColor:@"" fontSize:12 target:self action:@selector(defaultBtnClick:)];
        [defaultBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateSelected];
        defaultBtn.selected = YES;
        self.defaultBtn = defaultBtn;
        
        UIButton *sizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sizeBtn title:@"尺寸模式" titleColor:@"#888888" backgroundColor:@"" fontSize:12 target:self action:@selector(sizeBtnClick:)];
        [sizeBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateSelected];
        self.sizeBtn = sizeBtn;
        
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageBtn setImage:[UIImage bundleForImage:@"camera_photo"] forState:UIControlStateNormal];
        [imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [takeBtn setImage:[UIImage bundleForImage:@"camera_take"] forState:UIControlStateNormal];
        [takeBtn addTarget:self action:@selector(takeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setImage:[UIImage bundleForImage:@"camera_confirm"] forState:UIControlStateNormal];
        [confirmBtn setImage:[UIImage bundleForImage:@"camera_confirm_dis"] forState:UIControlStateDisabled];
        [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.resultImageArr.count > 0) {
            confirmBtn.enabled = YES;
        } else {
            confirmBtn.enabled = NO;
        }
        self.confirmBtn = confirmBtn;
        
        UILabel *numberLabel = [[UILabel alloc] init];
        [numberLabel textColor:@"#ffffff" textAlignment:(NSTextAlignmentCenter) fontSize:10];
        numberLabel.backgroundColor = [UIColor redColor];
        kRoundCorner(numberLabel, 10);
        if (self.resultImageArr.count > 0) {
            numberLabel.text = [NSString stringWithFormat:@"%ld",self.resultImageArr.count];
            numberLabel.hidden = NO;
        } else {
            numberLabel.hidden = YES;
        }
        self.numberLabel = numberLabel;
        
        [_toolBarView addSubview:tipLabel];
        [_toolBarView addSubview:defaultBtn];
        [_toolBarView addSubview:sizeBtn];
        [_toolBarView addSubview:imageBtn];
        [_toolBarView addSubview:takeBtn];
        [_toolBarView addSubview:confirmBtn];
        [_toolBarView addSubview:numberLabel];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(_toolBarView);
            make.bottom.mas_equalTo(_toolBarView.mas_top).offset(-4);
            make.height.mas_equalTo(@15);
        }];
        [defaultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(sizeBtn);
            make.top.mas_equalTo(sizeBtn);
            make.right.mas_equalTo(_toolBarView.mas_centerX).offset(-5);
        }];
        [sizeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(76, 25));
            make.top.mas_equalTo(_toolBarView).offset(10);
            make.left.mas_equalTo(_toolBarView.mas_centerX).offset(5);
        }];
        [imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(takeBtn);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.centerX.mas_equalTo(_toolBarView.mas_left).offset(kScreenWidth/6.f);
        }];
        [takeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_toolBarView).offset(-13-kIPhoneXBarOffset);
            make.centerX.mas_equalTo(_toolBarView);
            make.size.mas_equalTo(CGSizeMake(66, 66));
        }];
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(takeBtn);
            make.size.mas_equalTo(imageBtn);
            make.centerX.mas_equalTo(_toolBarView.mas_right).offset(-kScreenWidth/6.f);
        }];
        [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.bottom.mas_equalTo(confirmBtn.mas_centerY);
            make.right.mas_equalTo(confirmBtn.mas_left);
        }];
        
        [self.navigationController.view addSubview:_toolBarView];
    }
    return _toolBarView;
}

- (void)defaultBtnClick:(UIButton *)sender {
    if (!self.defaultBtn.selected && self.sizeBtn.selected) {
        self.defaultBtn.selected = YES;
        self.sizeBtn.selected = NO;
        
        self.tipLabel.text = @"拍照时请保持文档在框内";
        self.gridImageView.hidden = NO;
        
        self.sizeImageView.hidden = YES;
    }
}

- (void)sizeBtnClick:(UIButton *)sender {
    if (self.defaultBtn.selected && !self.sizeBtn.selected) {
        self.defaultBtn.selected = NO;
        self.sizeBtn.selected = YES;
        
        self.tipLabel.text = @"请选择一个尺寸";
        self.gridImageView.hidden = YES;
        
        //重置尺寸模式视图
        self.sizeImageView.hidden = NO;
        self.btnView.hidden = NO;
        self.maskView.hidden = YES;
    }
}

- (void)imageBtnClick:(UIButton *)sender {
    
    [TTool showLoadingInView:self.view];
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        [TTool hideInView:self.view];
    }];
}


- (void)takeBtnClick:(UIButton *)sender {
    if (![TScannerCamera sharedInstance].captureDevice) {
        return;
    }
    [self captureImageWithCompletionHander:^(UIImage *image) {
        TCropViewController *cropVC = [[TCropViewController alloc] init];
        cropVC.originalImage = [image fixOrientation];
        if (!self.maskView.hidden && self.sizeBtn.selected) {
            cropVC.sizeType = self.sizeType;
        } else {
            cropVC.sizeType = 1;
        }

        __weak typeof(self)ws = self;
        cropVC.clipImageBlock = ^(UIImage *image) {
            [ws addNewResultImage:image];
        };

        [self.navigationController pushViewController:cropVC animated:YES];
    }];
}

- (void)confirmBtnClick:(UIButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock(self.resultImageArr.copy);
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        TCustomPicBrowserViewController *browseVC = [[TCustomPicBrowserViewController alloc] init];
        browseVC.imagesArr = self.resultImageArr;
        [self.navigationController pushViewController:browseVC animated:YES];
    }

}


#pragma mark ===== ImagePickerControllerDelegate ===
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    self.imagePickerController = nil;
    
    if (photos.count > 0 && assets.count > 0) {
        
        if (isSelectOriginalPhoto) {
            [TTool showLoadingInView:self.view];
            [[TZImageManager manager] getOriginalPhotoWithAsset:assets.firstObject completion:^(UIImage *photo, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TCropViewController *cropVC = [[TCropViewController alloc] init];
                    cropVC.originalImage = [photo fixOrientation];
                    if (!self.maskView.hidden && self.sizeBtn.selected) {
                        cropVC.sizeType = self.sizeType;
                    } else {
                        cropVC.sizeType = 1;
                    }
                    __weak typeof(self)ws = self;
                    cropVC.clipImageBlock = ^(UIImage *image) {
                        [ws addNewResultImage:image];
                    };

                    [self.navigationController pushViewController:cropVC animated:YES];
                    [TTool hideInView:self.view];
                    
                    [picker dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        } else {
            [TTool showLoadingInView:self.view];
            dispatch_async(dispatch_get_main_queue(), ^{
                TCropViewController *cropVC = [[TCropViewController alloc] init];
                cropVC.originalImage = [photos.firstObject fixOrientation];
                if (!self.maskView.hidden && self.sizeBtn.selected) {
                    cropVC.sizeType = self.sizeType;
                } else {
                    cropVC.sizeType = 1;
                }
                __weak typeof(self)ws = self;
                cropVC.clipImageBlock = ^(UIImage *image) {
                    [ws addNewResultImage:image];
                };

                [self.navigationController pushViewController:cropVC animated:YES];
                [TTool hideInView:self.view];
                
                [picker dismissViewControllerAnimated:YES completion:nil];
            });
        }
        

    }
    
}


#pragma mark ==== Detection =====
- (void)initCameraConfig {
//    self.contentRect = self.view.bounds;
//    self.contentSize = self.view.bounds.size;
    
    self.contentRect = self.visibleRect;
    self.contentSize = self.visibleRect.size;
    
    [self setupCameraView];
    [self addTapGesture];
}

//初始化
- (void)setupCameraView {
    
    //grid
    [self addCameraGridView];
    [self addSizeImageView];
    
    if (![TScannerCamera sharedInstance].captureDevice) {
        return;
    }
    
    [[TScannerCamera sharedInstance].dataOutput setSampleBufferDelegate:self queue:_captureQueue];
    //预览实时信息
    [TScannerCamera sharedInstance].previewLayer.frame = self.contentRect;
    [self.view.layer insertSublayer:[TScannerCamera sharedInstance].previewLayer atIndex:0];

}

// 拍摄网格遮罩
- (void)addCameraGridView {
    self.gridImageView  = [[UIImageView alloc] initWithFrame:self.visibleRect];
    self.gridImageView.image = [UIImage bundleForImage:@"camera_grid"];
    [self.view addSubview:self.gridImageView ];
}

//尺寸模式遮罩
- (void)addSizeImageView {
    
    self.sizeImageView = [[UIImageView alloc] initWithFrame:self.visibleRect];
    self.sizeImageView.userInteractionEnabled = YES;
    self.sizeImageView.hidden = YES;
    [self.view addSubview:self.sizeImageView];
    
    //三个尺寸按钮
    [self.sizeImageView addSubview:self.btnView];
    
    //选中尺寸后的镂空遮罩
    self.maskView = [[TCameraSizeMaskView alloc] initWithFrame:_sizeImageView.bounds rulerTarget:self action:@selector(rulerBtnAction)];
    _maskView.hidden = YES;
    [_sizeImageView addSubview:self.maskView];

}

- (UIView *)btnView {
    if (!_btnView) {
        _btnView = [[UIView alloc] initWithFrame:self.sizeImageView.bounds];
        _btnView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.3];
        
        [self.sizeImageView addSubview:_btnView];
        
        //添加三个尺寸按钮
        self.btn_A4 = [[TCameraSizeBtn alloc] initWithLeftTitle:@"210x297mm" rightTitle:@"A4" target:self action:@selector(sizeModelChooseClick:)];
        self.btn_16K = [[TCameraSizeBtn alloc] initWithLeftTitle:@"185x260mm" rightTitle:@"16开" target:self action:@selector(sizeModelChooseClick:)];
        self.btn_A6 = [[TCameraSizeBtn alloc] initWithLeftTitle:@"105x148mm" rightTitle:@"A6" target:self action:@selector(sizeModelChooseClick:)];
        
        [_btnView addSubview:_btn_A4];
        [_btnView addSubview:_btn_16K];
        [_btnView addSubview:_btn_A6];
        
        CGFloat margin;
        if (iPhoneX) {
            margin = 20;
        } else {
            margin = 35;
        }
        
        if (kScreenHeight == 480) {
            margin = 65;
        }
//        A4像素：595x842(210x297mm)   16开像素：524x737(185x260mm)  A6像素：298x420(105x148mm)
        CGFloat W_A4 = _sizeImageView.bounds.size.width - margin * 2;
        CGFloat H_A4 = W_A4 * 842 / 595;
        
        CGFloat W_16K = W_A4 * 524 / 595;
        CGFloat H_16K = W_16K * 737 / 524;
        
        CGFloat W_A6 = W_A4 * 298 / 595;
        CGFloat H_A6 = W_A6 * 420 / 298;
        
        [_btn_A4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_btnView);
            make.size.mas_equalTo(CGSizeMake(W_A4, H_A4));
        }];
        [_btn_16K mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(_btn_A4);
            make.size.mas_equalTo(CGSizeMake(W_16K, H_16K));
        }];
        [_btn_A6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(_btn_A4);
            make.size.mas_equalTo(CGSizeMake(W_A6, H_A6));
        }];
    }
    return _btnView;
}

- (void)sizeModelChooseClick:(TCameraSizeBtn *)sender {
    self.btnView.hidden = YES;
    self.maskView.hidden = NO;
    [self.maskView addAnimationFromView:sender toView:self.btn_A4];
    
    if ([sender isEqual:self.btn_A4]) {
        self.sizeType = 1;
        self.tipLabel.text = @"适合拍摄论文、课题、合同...等接近A4尺寸的成果";
    } else if ([sender isEqual:self.btn_16K]) {
        self.sizeType = 2;
        self.tipLabel.text = @"适合拍摄英语证书...等接近16开尺寸的成果";
    } else {
        self.sizeType = 3;
        self.tipLabel.text = @"适合拍摄职称证...等接近A6尺寸的成果";
    }
    
}

- (void)rulerBtnAction {
    self.btnView.hidden = NO;
    self.maskView.hidden = YES;
}


//高精度矩形探测器
- (CIDetector *)highAccuracyRectangleDetector {
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                      context:nil
                                      options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh,
                                                CIDetectorImageOrientation:@(0),
                                                }];
    });
    return detector;
}






#pragma mark ====== 用户交互 ===
//聚焦手势
- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tap];
}
- (void)focusGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];
        [self focusAtPoint:location];
    }
}
//聚焦
- (void)focusAtPoint:(CGPoint)location {
    if (!self.focusIndicator || !self.focusIndicator.superview) {
        self.focusIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.focusIndicator.image = [UIImage bundleForImage:@"focusIndicator"];
        [self.view addSubview:self.focusIndicator];
    }
    self.focusIndicator.center = location;
    
    [self focusIndicatorAnimate];
    [self cameraFocusAtPoint:location device:[TScannerCamera sharedInstance].captureDevice completionHandler:^{
        [self focusIndicatorAnimate];
    }];
}
    
// 聚焦动画
- (void)focusIndicatorAnimate {
    
    self.focusIndicator.layer.opacity = 0.0f;
    self.focusIndicator.layer.affineTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    
    [UIView animateWithDuration:0.4 animations:^{
        self.focusIndicator.layer.affineTransform = CGAffineTransformIdentity;
        self.focusIndicator.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.focusIndicator.layer.opacity = 0.0f;
        }];
    }];
    
}
//相机聚焦处理
- (void)cameraFocusAtPoint:(CGPoint)point device:(AVCaptureDevice *)device completionHandler:(void(^)(void))completionHandler {
    
    CGPoint pointOfInterest = CGPointZero;
    
    pointOfInterest = CGPointMake(point.y / self.contentSize.height, 1.f - (point.x / self.contentSize.width));
    
    if ([device lockForConfiguration:nil]) {

        if ([device isFocusPointOfInterestSupported]) {
            [device setFocusPointOfInterest:pointOfInterest];
        }
        if ([device isFocusModeSupported:(AVCaptureFocusModeContinuousAutoFocus)]) {
            [device setFocusMode:(AVCaptureFocusModeContinuousAutoFocus)];
        }
        
        if([device isExposurePointOfInterestSupported]) {
            [device setExposurePointOfInterest:pointOfInterest];
        }
        if ([device isExposureModeSupported:(AVCaptureExposureModeContinuousAutoExposure)]) {
            [device setExposureMode:(AVCaptureExposureModeContinuousAutoExposure)];
        }
        
        if ([device isWhiteBalanceModeSupported:(AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)]) {
            [device setWhiteBalanceMode:(AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)];
        }
        
        [device unlockForConfiguration];
        
        completionHandler();
    }
}



#pragma mark ===== 滤镜 ====

- (UIImage *)imageByFilterGroup:(UIImage *)image {
    GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    [picture addTarget:filterGroup];

    //饱和度 (0 - 2)
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    saturationFilter.saturation = 1.1;

    //对比度 (0 - 4)
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    contrastFilter.contrast = 1.4;

    //锐化 (-4 - 4)
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 1.05;

    [self addGPUImageFilter:saturationFilter toFilterGroup:filterGroup];
    [self addGPUImageFilter:contrastFilter toFilterGroup:filterGroup];
    [self addGPUImageFilter:sharpenFilter toFilterGroup:filterGroup];

    [picture processImage];
    [filterGroup useNextFrameForImageCapture];

    UIImage *outputImage = [filterGroup imageFromCurrentFramebuffer];
    
    return outputImage ?: image;
}

- (UIImage *)imageByContrastFilter:(UIImage *)image {
    //对比度 (0 - 4)
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    contrastFilter.contrast = 4;
    return [contrastFilter imageByFilteringImage:image];
}



- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter toFilterGroup:(GPUImageFilterGroup *)filterGroup {
    
    [filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = filterGroup.filterCount;
    
    if (count == 1) {
        
        filterGroup.initialFilters = @[newTerminalFilter];
        filterGroup.terminalFilter = newTerminalFilter;
        
    } else {
        GPUImageOutput<GPUImageInput> *terminalFilter    = filterGroup.terminalFilter;
        NSArray *initialFilters                          = filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        filterGroup.initialFilters = @[initialFilters[0]];
        filterGroup.terminalFilter = newTerminalFilter;
    }
}



//方向矫正
- (CIImage *)correctImage:(CIImage *)inputImage {
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:inputImage forKey:kCIInputImageKey];
    
    NSValue *rotation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(-90 * (M_PI/180))];
    [transform setValue:rotation forKey:kCIInputTransformKey];
    
    return [transform outputImage];
}




// 坐标仿射变换 - 绘制遮罩层
- (IPDFRectangleFeature *)coordinateTransformationForRectangleFeature:(CIRectangleFeature *)feature ciImage:(CIImage *)image {
    
    CGSize imageSize = image.extent.size;
    
    CGFloat scale = MIN(imageSize.width / self.contentSize.width, imageSize.height / self.contentSize.height);
    
    //scale
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1/scale, 1/scale);
    CGPoint topLeft = CGPointApplyAffineTransform(feature.topLeft, transform);
    CGPoint topRight = CGPointApplyAffineTransform(feature.topRight, transform);
    CGPoint bottomLeft = CGPointApplyAffineTransform(feature.bottomLeft, transform);
    CGPoint bottomRight = CGPointApplyAffineTransform(feature.bottomRight, transform);
    
    //rotate coordinate-Y + offset
    CGFloat off_x = (self.contentSize.width - imageSize.width / scale) / 2;
    CGFloat off_y = (self.contentSize.height - imageSize.height / scale) / 2;
    
    topLeft = CGPointMake(topLeft.x + off_x, self.contentSize.height - topLeft.y - off_y);
    topRight = CGPointMake(topRight.x + off_x, self.contentSize.height - topRight.y - off_y);
    bottomRight = CGPointMake(bottomRight.x + off_x, self.contentSize.height - bottomRight.y - off_y);
    bottomLeft = CGPointMake(bottomLeft.x + off_x, self.contentSize.height - bottomLeft.y - off_y);
    
    
    IPDFRectangleFeature *transformFeature = [[IPDFRectangleFeature alloc] init];
    transformFeature.topLeft = topLeft;
    transformFeature.topRight = topRight;
    transformFeature.bottomLeft = bottomLeft;
    transformFeature.bottomRight = bottomRight;
    
    return transformFeature;
    
}


// 绘制边缘检测高亮层
- (CAShapeLayer *)drawHighlightOverlayForRectangleFeature:(IPDFRectangleFeature *)feature {
    UIColor *layerColor;
    UIColor *borderColor;
//    if (_imageDedectionConfidence > 10) {
//        layerColor = [UIColor colorWithRed:0.0 green:1 blue:0.0 alpha:0.3];
//        borderColor = [UIColor colorWithRed:0.0 green:1 blue:0 alpha:1.0];
//    } else {
        layerColor = [UIColor colorWithHexString:MAIN_COLOR_S alpha:0.3];
        borderColor = [UIColor colorWithHexString:MAIN_COLOR_S alpha:1.0];
//    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:feature.topLeft];
    [path addLineToPoint:feature.topRight];
    [path addLineToPoint:feature.bottomRight];
    [path addLineToPoint:feature.bottomLeft];
    [path addLineToPoint:feature.topLeft];
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.contentRect;
    shapeLayer.fillColor = layerColor.CGColor;
    shapeLayer.strokeColor = borderColor.CGColor;
    
    
    return shapeLayer;
}




- (CIImage *)filteredImageUsingContrastFiltersOnImage:(CIImage *)image {
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.0),kCIInputImageKey:image}].outputImage;
}


#pragma mark ======= AVCaptureVideoDataOutputSampleBufferDelegate ======
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_isStopped  || _isCapturing || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    if (self.enableBorderDetection) {
        self.enableBorderDetection = NO;
//        image = [CIImage imageWithCGImage: [self imageByContrastFilter:[self drawImage:image]].CGImage];//滤镜处理  消耗cpu 但是快
        image = [self filteredImageUsingContrastFiltersOnImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[TScannerCamera sharedInstance].overLayer  removeFromSuperlayer];
            
            CIDetector *detector = [self highAccuracyRectangleDetector];
            NSArray *features = [detector featuresInImage:image];
            if (features.count) {
                
                CGFloat area = [TIPDFCalculateManager areaOfTheQuadrilateral:features.firstObject];
                CGFloat difference = fabs(self.lastRectangleArea - area);
                CGFloat errorValue = fabs(self.lastRectangleArea * 0.05);//误差5%
                self.lastRectangleArea = area;

                if (difference < errorValue) {
                    _imageDedectionConfidence += 0.5;
                }
                
                
                if (_imageDedectionConfidence > 10 && difference > errorValue*3) {//误差15%
                    _errorDedectionConfidence += 0.5;//不显示
                } else {
                    self.lastRectangleArea = area;
                    self.borderDetectLastRectangleFeature = features.firstObject;
                    self.realRectangleFeature = [self coordinateTransformationForRectangleFeature:self.borderDetectLastRectangleFeature ciImage:image];
                    CAShapeLayer *overLayer = [self drawHighlightOverlayForRectangleFeature:self.realRectangleFeature];
                    [[TScannerCamera sharedInstance].previewLayer addSublayer:overLayer];
                    [TScannerCamera sharedInstance].overLayer = overLayer;
                    
                    if (_errorDedectionConfidence > 5) {
                        _imageDedectionConfidence = 0;
                        _errorDedectionConfidence = 0;
                    }
                }

                
            } else {
                _imageDedectionConfidence = 0.0f;
                _errorDedectionConfidence = 0;
            }
        });
    }
    

}




#pragma mark ====== 拍摄 ====
- (void)captureImageWithCompletionHander:(void(^)(UIImage *image))completionHandler {
    
    if (_isCapturing) {
        return;
    }
    
    [TTool showLoadingInView:self.view];
    _isCapturing = YES;
    dispatch_suspend(_captureQueue);
    AVCaptureConnection *videoConnection = [[TScannerCamera sharedInstance].stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [[TScannerCamera sharedInstance].stillImageOutput  captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        CIImage *enhancedImage = [[CIImage alloc] initWithData:imageData options:@{kCIImageColorSpace:[NSNull null]}];
        
        enhancedImage = [self filteredImageUsingContrastFiltersOnImage:enhancedImage];
        
        //翻转90度矫正
        enhancedImage = [self correctImage:enhancedImage];
        
        // 图片绘制
        UIImage *outputImage = [self drawImage:enhancedImage];
        
        //裁剪
//        outputImage = [self clipImage:outputImage];
        
        //滤镜处理
//        outputImage = [self imageByFilterGroup:outputImage];
        
        //回调
        dispatch_async(dispatch_get_main_queue(), ^ {
            [TTool hideInView:self.view];
            _isCapturing = NO;
            dispatch_resume(_captureQueue);
            completionHandler(outputImage);
        });
    }];
}

//图片绘制
- (UIImage *)drawImage:(CIImage *)inputImage {
    static CIContext *ctx = nil;
    if (!ctx) {
        ctx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
    }
    
    CGSize bounds = inputImage.extent.size;
    
    static int bytesPerPixel = 8;
    uint rowBytes = bytesPerPixel * floorf(bounds.width);
    uint totalBytes = rowBytes * floorf(bounds.height);
    uint8_t *byteBuffer = malloc(totalBytes);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    [ctx render:inputImage toBitmap:byteBuffer rowBytes:rowBytes bounds:inputImage.extent format:kCIFormatRGBA8 colorSpace:colorSpace];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(byteBuffer,bounds.width,bounds.height,bytesPerPixel,rowBytes,colorSpace,kCGImageAlphaNoneSkipLast);
    CGImageRef imgRef = CGBitmapContextCreateImage(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    free(byteBuffer);
    
    UIImage *outputImage = [UIImage imageWithCGImage:imgRef];
    CFRelease(imgRef);
    
    return outputImage;
}

// 裁剪可见区域的图片 所见即所得
- (UIImage *)clipImage:(UIImage *)image {
    
    CGRect clipFrame = CGRectMake(0, (kScreenHeight - self.visibleRect.size.height)/2, self.visibleRect.size.width, self.visibleRect.size.height);
    
    CGFloat scaleX = image.size.width / clipFrame.size.width;
    CGFloat scaleY = image.size.height / clipFrame.size.height;
    CGFloat scale = MIN(scaleX, scaleY);

    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, scale, scale);
    UIImage *clipImage = [image croppedImage:CGRectApplyAffineTransform(clipFrame, transform)];
    
    return clipImage;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





//根据边缘检测的矩形判断当前相机的拍摄角度
- (IPDFDetectRectangeQualityType) detectionQualityTypeForRectangle: (IPDFRectangleFeature *)feature {
    
    //对比矩形各个顶点的差值
    CGFloat diff_1 = fabs(feature.topRight.y - feature.topLeft.y);
    CGFloat diff_2 = fabs(feature.topRight.x - feature.bottomRight.x);
    CGFloat diff_3 = fabs(feature.topLeft.x - feature.bottomLeft.x);
    CGFloat diff_4 = fabs(feature.bottomLeft.y - feature.bottomRight.y);
    
    
    //计算矩形的尺寸
    NSArray * points_x = @[@(feature.topLeft.x), @(feature.topRight.x),@(feature.bottomLeft.x),@(feature.bottomRight.x)];
    NSArray * points_y = @[@(feature.topLeft.y), @(feature.topRight.y),@(feature.bottomLeft.y),@(feature.bottomRight.y)];
    CGFloat min_x = [[points_x valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat max_x = [[points_x valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat min_y = [[points_y valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat max_y = [[points_y valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat width = max_x - min_x;
    CGFloat height = max_y - min_y;
    
    if (diff_1 > 100 || diff_2 > 100 || diff_3 > 100 || diff_4 > 100) {
        
        return IPDFDetectRectangeQualityTypeBadAngle;
        
    } else if (width < 150 || height < 150) {
        
        return IPDFDetectRectangeQualityTypeTooFar;
    }
    return IPDFDetectRectangeQualityTypeGood;
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
