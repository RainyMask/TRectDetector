
//  Created by tao on 2018/7/25.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TTool.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


static NSString     *ERRORSTRING = @"网络状态不佳...";
static CGFloat      MARGIN = 10.0f;
static CGFloat      FONT = 16;

@implementation TTool

+ (void)showLoadingInView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.activityIndicatorColor = [UIColor whiteColor];
    hud.bezelView.color = [UIColor colorWithHexString:@"#4c4c4c" alpha:1];
    hud.minSize = CGSizeMake(60, 60);
//    hud.offset = CGPointMake(0, -kIPhoneXNavHeight);
}

+ (void)showLoadingInView:(UIView *)view title:(NSString *)title {
    if (title.length == 0) {
        [self showLoadingInView:view];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.activityIndicatorColor = [UIColor whiteColor];
    hud.bezelView.color = [UIColor colorWithHexString:@"#4c4c4c" alpha:1];
    hud.minSize = CGSizeMake(kScreenWidth/3, kScreenWidth/3);
//    hud.offset = CGPointMake(0, -kIPhoneXNavHeight);

    
    hud.detailsLabel.text = title;
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:FONT];
}

+ (void)showMessageInView:(UIView *)view title:(NSString *)title {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor colorWithHexString:@"#4c4c4c" alpha:1];
    hud.userInteractionEnabled = NO;
    
    hud.detailsLabel.text = title.length ? title : ERRORSTRING;
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:FONT];
    
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.margin = MARGIN;
    hud.offset = CGPointMake(0, kScreenHeight / 2.0f - 60.0f);//MBProgressMaxOffset
    [hud hideAnimated:YES afterDelay:1.5f];
}

+ (void)showMessageInCenterView:(UIView *)view title:(NSString *)title { //屏幕中间
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor colorWithHexString:@"#4c4c4c" alpha:1];
    hud.userInteractionEnabled = NO;
    
    hud.detailsLabel.text = title.length ? title : ERRORSTRING;
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:FONT];
    
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.margin = MARGIN;
    [hud hideAnimated:YES afterDelay:1.5f];
}


+ (void)hideInView:(UIView *)view {
    BOOL success = [MBProgressHUD hideHUDForView:view animated:YES];
    if (!success) {
        [MBProgressHUD hideHUDForView:view animated:YES];
    }
}

















+ (void)showPhotoLibaryAuthorizationFromViewController:(UIViewController *)vc success:(void(^)(void))success{
    
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusAuthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                        break;
                    default:
                        [self showAlertInViewController:vc  featureName:@"相册"];
                        break;
                }
            }];
        }
            break;
        default:
            [self showAlertInViewController:vc  featureName:@"相册"];
            break;
    }
}

+ (void)showCameraAuthorizationFromViewController:(UIViewController *)vc success:(void(^)(void))success {
    
    //获取权限
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
            break;
            
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted ){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success();
                    });
                } else {
                    [self showAlertInViewController:vc featureName:@"相机"];
                }
            }];
        }
            break;
        default:
            [self showAlertInViewController:vc  featureName:@"相机"];
            break;
    }
}

+ (void)showAlertInViewController:(UIViewController *)vc featureName:(NSString *)featureName {
    // app名称
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *message = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-%@”中允许%@访问%@", featureName, app_Name, featureName];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"无法使用%@",featureName] message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:setting];
    [vc presentViewController:alertVC animated:YES completion:nil];
}


@end
