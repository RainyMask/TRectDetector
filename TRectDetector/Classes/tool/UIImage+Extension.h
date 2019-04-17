//
//  UIImage+Extension.h
//  efangTec
//
//  Created by air on 2017/5/27.
//  Copyright © 2017年 efangtec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**修正图片的旋转角度 0 度*/
- (UIImage *)fixOrientation;

/**图片压缩，等宽高*/
- (UIImage *)compressToWidth:(CGFloat)defineWidth;

/**图片压缩*/
- (UIImage *)compressToSize:(CGSize)defineSize;

/**绘制虚线图片*/
+ (UIImage *)drawLineOfDashByImageView:(UIImageView *)imageView color:(UIColor *)color;


+ (UIImage *)imageWithColor:(UIColor *)color;

/** 压缩图片质量  二分法优化 */
//+ (UIImage *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;

/** 获取图片的主色调*/
+ (UIColor *)mainColorOfImage:(UIImage *)image;

@end
