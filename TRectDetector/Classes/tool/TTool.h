//
//
//  Created by tao on 2018/7/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THeader.h"

@interface TTool : NSObject

+ (void)showLoadingInView:(UIView *)view;
+ (void)showLoadingInView:(UIView *)view title:(NSString *)title;
+ (void)showMessageInView:(UIView *)view title:(NSString *)title;
+ (void)showMessageInCenterView:(UIView *)view title:(NSString *)title;//屏幕中间
+ (void)hideInView:(UIView *)view;


//相机权限
+ (void)showCameraAuthorizationFromViewController:(UIViewController *)vc success:(void(^)(void))success;

+ (void)showPhotoLibaryAuthorizationFromViewController:(UIViewController *)vc success:(void(^)(void))success;

@end
