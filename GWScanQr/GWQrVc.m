//
//  GWQrVc.m
//  GWScanQr
//
//  Created by MacBook on 2017/9/4.
//  Copyright © 2017年 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import "GWQrVc.h"
#import "GWScanQr.h"

@interface GWQrVc ()<GWScanCodeManagerDelegate>
@property (retain,nonatomic)GWScanQRvC * scanQr;

@end

@implementation GWQrVc

-(GWScanQRvC *)scanQr
{
    if (!_scanQr)
    {
        _scanQr = [[GWScanQRvC alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];
        _scanQr.titleL.text = @"Please scan a QR code";
        _scanQr.backgroundAlpha = 0.45f;
        [_scanQr addTimer];
    }
    return _scanQr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.scanQr];
    [[GWScanCodeManager sharedScanQR]ScanQR:AVCaptureSessionPreset1920x1080 currentController:self];
    [GWScanCodeManager sharedScanQR].delegate = self;
}

-(void)captureOutput:(GWScanCodeManager *)ScanQr didOutputMetadataObjects:(NSArray *)metadataObjects
{
    NSLog(@"metadataObjects = %@",metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0)
    {
        [ScanQr GWStopRunning];
        [ScanQr SWPlaySoundName:@"SGQRCode.bundle/sound.caf"];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects.firstObject;
        NSString * qrS = [obj stringValue];
        NSLog(@"Scanqr = %@",qrS);
    }else
    {
        
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scanQr removeTimer];
    [[GWScanCodeManager sharedScanQR]GWStopRunning];
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
