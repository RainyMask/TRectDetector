//
//  UIImage+Extension.m
//  efangTec
//
//  Created by air on 2017/5/27.
//  Copyright © 2017年 efangtec. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


- (UIImage *)fixOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//图片压缩，等宽高
- (UIImage *)compressToWidth:(CGFloat)defineWidth {
    UIGraphicsBeginImageContext(CGSizeMake(defineWidth, defineWidth));
    [self drawInRect:CGRectMake(0,0,defineWidth,  defineWidth)];
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**图片压缩*/
- (UIImage *)compressToSize:(CGSize)defineSize {
    UIGraphicsBeginImageContext(CGSizeMake(defineSize.width, defineSize.height));
    [self drawInRect:CGRectMake(0,0,defineSize.width,  defineSize.height)];
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**绘制虚线图片*/
+ (UIImage *)drawLineOfDashByImageView:(UIImageView *)imageView color:(UIColor *)color {
    // 开始划线 划线的frame
    UIGraphicsBeginImageContext(imageView.frame.size);
    
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    
    // 获取上下文
    CGContextRef line = UIGraphicsGetCurrentContext();
    
    // 设置线条终点的形状
    CGContextSetLineCap(line, kCGLineCapRound);
    // 设置虚线的长度 和 间距
    CGFloat lengths[] = {5,2};
    
    CGContextSetStrokeColorWithColor(line, color.CGColor);
    // 开始绘制虚线
    CGContextSetLineDash(line, 0, lengths, 2);
    
    CGContextMoveToPoint(line, 0.0, 2.0);
    
    CGContextAddLineToPoint(line, imageView.frame.size.width, 2.0);
    
    CGContextStrokePath(line);
    
    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    return UIGraphicsGetImageFromCurrentImageContext();
}


+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (UIImage *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    return resultImage;
}



+ (UIColor *)mainColorOfImage:(UIImage *)image {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    
    int bitmapInfo =kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    
#else
    
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
    
#endif
    
    //第一步：先把图片缩小，加快计算速度，但越小结果误差可能越大
    
    CGSize thumbSize=CGSizeMake(50,50);
    
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context =CGBitmapContextCreate(NULL,
                                                
                                                thumbSize.width,
                                                
                                                thumbSize.height,
                                                
                                                8,//bits per component
                                                
                                                thumbSize.width*4,
                                                
                                                colorSpace,
                                                
                                                bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    
    CGContextDrawImage(context, drawRect, image.CGImage);
    
    CGColorSpaceRelease(colorSpace);
    
    //第二步：取每个点的像素值
    
    unsigned char* data =CGBitmapContextGetData (context);
    
    if (data == NULL) {
        return [UIColor clearColor];
    }
    
    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    
    for (int x=0; x<thumbSize.width; x++) {
        
        for (int y=0; y<thumbSize.height; y++) {
            
            int offset = 4*(x*y);
            
            int red = data[offset];
            
            int green = data[offset+1];
            
            int blue = data[offset+2];
            
            int alpha =  data[offset+3];
            
            
            
            NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
            
            [cls addObject:clr];
            
        }
        
    }
    
    CGContextRelease(context);
    
    //第三步：找到出现次数最多的那个颜色
    
    NSEnumerator *enumerator = [cls objectEnumerator];
    
    NSArray *curColor = nil;
    
    NSArray *MaxColor=nil;
    
    NSUInteger MaxCount=0;
    
    while ( (curColor = [enumerator nextObject]) != nil ){
        
        NSUInteger tmpCount = [cls countForObject:curColor];
        
        if (tmpCount < MaxCount) continue;
        
        MaxCount=tmpCount;
        
        MaxColor=curColor;
        
    }
    
    return [UIColor colorWithRed:([MaxColor[0]intValue]/255.0f)green:([MaxColor[1]intValue]/255.0f)blue:([MaxColor[2]intValue]/255.0f)alpha:([MaxColor[3]intValue]/255.0f)];
    
}

@end
