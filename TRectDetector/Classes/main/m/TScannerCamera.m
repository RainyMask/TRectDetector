//
//  TScannerCamera.m
//  YKYClient
//
//  Created by tao on 2018/9/17.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TScannerCamera.h"

@implementation TScannerCamera

+ (instancetype)sharedInstance {
    static TScannerCamera *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TScannerCamera alloc] init];
        }
    });
    return instance;
}



- (AVCaptureDevice *)captureDevice {
    if (!_captureDevice) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionBack) {
                _captureDevice = device;
                break;
            }
        }
        
        if (!_captureDevice) {
            return nil;
        }
        
        [_captureDevice lockForConfiguration:nil];
        //聚焦点
        if ([_captureDevice isFocusPointOfInterestSupported]) {
            [_captureDevice setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
        }
        //自动连续聚焦
        if ([_captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动持续曝光
        if ([_captureDevice isExposureModeSupported:(AVCaptureExposureModeContinuousAutoExposure)]) {
            [_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动持续白平衡
        if ([_captureDevice isWhiteBalanceModeSupported:(AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)]) {
            [_captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //允许低亮度下提高亮度
        if ([_captureDevice isLowLightBoostSupported]) {
            [_captureDevice setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
        }
        //允许监视区域改变
        [_captureDevice setSubjectAreaChangeMonitoringEnabled:YES];
        
        [_captureDevice unlockForConfiguration];
        
    }
    return _captureDevice;
}

- (AVCaptureVideoDataOutput *)dataOutput {
    if (!_dataOutput) {
        _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_dataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    }
    return _dataOutput;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _stillImageOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        
        _captureSession = [[AVCaptureSession alloc] init];
        
        [_captureSession beginConfiguration];
        
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        if ([_captureSession canAddInput:input]) {
            [_captureSession addInput:input];
        }
        
        if ([_captureSession canAddOutput:self.dataOutput]) {
            [_captureSession addOutput:self.dataOutput];
        }
        
        AVCaptureConnection *connection = [self.dataOutput.connections firstObject];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic]; //开启防抖动模式
        
        if ([_captureSession canAddOutput:self.stillImageOutput]) {
            [_captureSession addOutput:self.stillImageOutput];
        }
        
        [_captureSession commitConfiguration];
        
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

@end
