//
//  CameraSizeBtn.h
//  YKYClient
//
//  Created by tao on 2018/8/3.
//  Copyright © 2018年 tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@interface CameraSizeBtn : UIButton

@property (nonatomic, strong) NSString *leftTitle;
@property (nonatomic, strong) NSString *rightTitle;

- (instancetype)initWithLeftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle target:(id)target action:(SEL)action;

@end
