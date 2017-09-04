//
//  ViewController.m
//  GWScanQr
//
//  Created by MacBook on 2017/9/4.
//  Copyright © 2017年 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "GWQrVc.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)Scan:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    [[GWScanCodeManager sharedScanQR]GWSacnQR:^(BOOL grant)
     {
         if (grant)
         {
             GWQrVc * qr = [[GWQrVc alloc]init];
             [weakSelf.navigationController pushViewController:qr animated:YES];
         }
     }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
