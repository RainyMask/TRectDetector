//
//  TBaseNavViewController.m
//  YKYClient
//
//  Created by tao on 2018/7/24.
//  Copyright © 2018年 tao. All rights reserved.
//

#import "TBaseNavViewController.h"
#import "UIBarButtonItem+TExtension.h"

@interface TBaseNavViewController ()

@end

@implementation TBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTargat:self action:@selector(popBack) image:@"back" highImage:@"back"];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)popBack {
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
