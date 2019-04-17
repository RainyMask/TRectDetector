//
//  ScannerCamera.h
//  YKYClient
//
//  Created by tao on 2018/9/17.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>

@interface ScannerCamera : NSObject

@property (nonatomic,strong) AVCaptureDevice *captureDevice;

@property (nonatomic,strong) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) CAShapeLayer *overLayer;


+ (instancetype)sharedInstance;

@end
