//
//  GWQrFlashlightsManager.m
//  ZTCallLinPhone
//
//  Created by MacBook on 2017/9/4.
//  Copyright © 2017年 2017 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import "GWQrFlashlightsManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation GWQrFlashlightsManager

+(GWQrFlashlightsManager *)sharedQrFlashlightsManager
{
    static GWQrFlashlightsManager * QrflashLight = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QrflashLight = [self new];
    });
    return QrflashLight;
}

-(void)GWOpenFlashLight
{
    AVCaptureDevice * capture = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError * error = nil;
    if ([capture hasTorch])
    {
        BOOL locked = [capture lockForConfiguration:&error];
        if (locked)
        {
            capture.torchMode = AVCaptureTorchModeOn;
            [capture unlockForConfiguration];
        }
    }
}

-(void)GWCloseFlashLight
{
    AVCaptureDevice * capture = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([capture hasTorch])
    {
        [capture lockForConfiguration:nil];
        [capture setTorchMode: AVCaptureTorchModeOff];
        [capture unlockForConfiguration];
    }
}




@end
