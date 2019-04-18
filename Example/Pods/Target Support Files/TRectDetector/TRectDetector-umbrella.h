#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BaseNavViewController.h"
#import "BaseViewController.h"
#import "CropViewController.h"
#import "CustomPicBrowserViewController.h"
#import "ScannerViewController.h"
#import "Header.h"
#import "IPDFCalculateManager.h"
#import "ScannerCamera.h"
#import "CameraSizeBtn.h"
#import "CameraSizeMaskView.h"
#import "MagnifierView.h"
#import "PictureCollectionCell.h"
#import "KKBaseShow.h"
#import "UIBarButtonItem+Extension.h"
#import "UIButton+Extension.h"
#import "UIColor+Hex.h"
#import "UIImage+Alpha.h"
#import "UIImage+Extension.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UILabel+Extension.h"

FOUNDATION_EXPORT double TRectDetectorVersionNumber;
FOUNDATION_EXPORT const unsigned char TRectDetectorVersionString[];

