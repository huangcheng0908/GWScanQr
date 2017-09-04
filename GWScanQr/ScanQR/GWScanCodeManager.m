//
//  GWScanCodeManager.m
//  ZTCallLinPhone
//
//  Created by MacBook on 2017/9/1.
//  Copyright © 2017年 2017 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import "GWScanCodeManager.h"

@implementation GWScanCodeManager

+(GWScanCodeManager *)sharedScanQR
{
    static GWScanCodeManager * scanQr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scanQr = [[GWScanCodeManager alloc]init];
    });
    return scanQr;
}

-(void)GWSacnQR:(void(^)(BOOL grant))grant
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device)
    {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized)
        {
            grant(YES);
        }else if (status == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
            {
                grant(granted);
            }];
        }else if (status == AVAuthorizationStatusDenied)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"检测到该设备没有授权开启摄像头" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"检测到该设备没有可用的摄像头" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)ScanQR:(NSString *)sessionPreset currentController:(UIViewController *)currentController
{
    // 获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 创建设备输入流
    NSError * error = nil;
    AVCaptureDeviceInput * deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//    创建数据输出流
    AVCaptureMetadataOutput * metadataOutput = [[AVCaptureMetadataOutput alloc]init];
//    创建设备输出流
    AVCaptureVideoDataOutput * videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    //    metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、创建会话对象
    _session = [[AVCaptureSession alloc] init];
    // 会话采集率: AVCaptureSessionPresetHigh
    _session.sessionPreset = sessionPreset;
    // 6、添加设备输入流到会话对象
    [_session addInput:deviceInput];
    
    // 7、添加设备输出流到会话对象
    [_session addOutput:metadataOutput];
    // 7(1)添加设备输出流到会话对象；与 3(1) 构成识别光线强弱
    [_session addOutput:videoDataOutput];
    
    // 8、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    // @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 9、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    // 保持纵横比；填充层边界
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.frame = currentController.view.layer.bounds;
    [currentController.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    // 10、启动会话
    [_session startRunning];
    
}

#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"metadataObjects = %@",metadataObjects);
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputMetadataObjects:)])
    {
        [self.delegate captureOutput:self didOutputMetadataObjects:metadataObjects];
    }
}

#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 这个方法会时时调用，但内存很稳定
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary * metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    
    NSDictionary * exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:)])
    {
        [self.delegate captureOutput:self didOutputSampleBuffer:brightnessValue];
    }
    NSLog(@"%f",brightnessValue);
    
}

- (void)GWStartRunning
{
    [_session startRunning];
}

- (void)GWStopRunning
{
    [_session stopRunning];
    _session = nil;
}

- (void)GWVideoPreviewLayerRemoveFromSuperlayer
{
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)SWPlaySoundName:(NSString *)name
{
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID); // 播放音效
}

void soundCompleteCallback(SystemSoundID soundID, void *clientData)
{
    
}














@end
