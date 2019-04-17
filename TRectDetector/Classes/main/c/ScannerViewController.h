//
//  ScannerViewController.h
//  YKYClient
//
//  Created by tao on 2018/7/24.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "BaseViewController.h"

/** 边界值 */
@interface IPDFRectangleFeature : NSObject

@property (nonatomic,assign) CGPoint topLeft;
@property (nonatomic,assign) CGPoint topRight;
@property (nonatomic,assign) CGPoint bottomRight;
@property (nonatomic,assign) CGPoint bottomLeft;

@property (nonatomic,assign) CGPoint leftMiddle;
@property (nonatomic,assign) CGPoint topMiddle;
@property (nonatomic,assign) CGPoint rightMiddle;
@property (nonatomic,assign) CGPoint bottomMiddle;


- (instancetype)initWithFeature:(IPDFRectangleFeature *)feature;

@end

/** 相机拍摄角度 */
typedef NS_ENUM(NSInteger, IPDFDetectRectangeQualityType)
{
    IPDFDetectRectangeQualityTypeGood,
    IPDFDetectRectangeQualityTypeBadAngle,
    IPDFDetectRectangeQualityTypeTooFar
};


/** 文档扫描 Class */
@interface ScannerViewController : BaseViewController

/**存取保存的图片*/
@property (nonatomic, strong) NSMutableArray *resultImageArr;
/**图片选取确认后的回调*/
@property (nonatomic, copy) void(^confirmBlock)(NSArray *imagesArr);


@end
