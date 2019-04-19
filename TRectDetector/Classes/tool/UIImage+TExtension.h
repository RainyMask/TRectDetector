//
//  UIImage+TExtension.h
//  TRectDetector
//
//  Created by tao on 2019/4/19.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TExtension)

 + (UIImage *)bundleForImage:(NSString *)name; 


// UIImage+Alpha
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;


// UIImage+Extension
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


// UIImage+Resize
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;


// UIImage+RounderCorner
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;

@end

NS_ASSUME_NONNULL_END
