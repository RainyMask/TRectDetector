//
//  TCameraSizeBtn.m
//  YKYClient
//
//  Created by tao on 2018/8/3.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TCameraSizeBtn.h"

static NSString *COLOR = @"#888888";

@implementation TCameraSizeBtn

- (instancetype)initWithLeftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle target:(id)target action:(SEL)action {
    if (self = [super init]) {
        
        self.leftTitle = leftTitle;
        self.rightTitle = rightTitle;
        
        kBorder(self, 2, [UIColor colorWithHexString:COLOR]);
        
        UILabel *leftLabel = [[UILabel alloc] init];
        [leftLabel textColor:COLOR textAlignment:(NSTextAlignmentLeft) fontSize:11];
        leftLabel.text = leftTitle;
        
        UILabel *rightLabel = [[UILabel alloc] init];
        [rightLabel textColor:COLOR textAlignment:(NSTextAlignmentRight) fontSize:11];
        rightLabel.text = rightTitle;
        
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:leftLabel];
        [self addSubview:rightLabel];
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(5);
            make.top.mas_equalTo(self).offset(8);
        }];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-5);
            make.top.mas_equalTo(leftLabel);
        }];
    }
    return self;
}

@end
