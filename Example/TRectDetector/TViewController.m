//
//  TViewController.m
//  TRectDetector
//
//  Created by 1370254410@qq.com on 04/17/2019.
//  Copyright (c) 2019 1370254410@qq.com. All rights reserved.
//

#import "TViewController.h"

#import "TScannerViewController.h"
#import "TBaseNavViewController.h"

@interface TViewController ()

@end

@implementation TViewController
- (IBAction)start:(id)sender {
    
    TBaseNavViewController *nav = [[TBaseNavViewController alloc] initWithRootViewController: [[TScannerViewController alloc] init]];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
