//
//  GWScanQRvC.m
//  ZTCallLinPhone
//
//  Created by MacBook on 2017/9/4.
//  Copyright © 2017年 2017 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import "GWScanQRvC.h"

#define IS_KIPHONE      [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define kzWidth               self.frame.size.width
#define kzHeight              self.frame.size.height
//#define kHolewidth               200
//#define kHoleheight               200

//(iphone)
/** 扫描内容的 W 值 */
#define scanBorderW     0.7 * self.frame.size.width
/** 扫描内容的 x 值 */
#define scanBorderX     0.5 * (1 - 0.7) * self.frame.size.width
/** 扫描内容的 Y 值 */
#define scanBorderY     0.5 * (self.frame.size.height - scanBorderW)

//(ipad)
/** 扫描内容的 W 值 */
#define scanBorderW_ipad    0.4 * self.frame.size.width
/** 扫描内容的 x 值 */
#define scanBorderX_ipad    0.5 * (1 - 0.4) * self.frame.size.width
/** 扫描内容的 Y 值 */
#define scanBorderY_ipad    0.5 * (self.frame.size.height - scanBorderW_ipad)


@implementation GWScanQRvC

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self initSetupVc];
    }
    return self;
}

-(void)initSetupVc
{
    _scanningAnimationStyle = ScanningAnimationStyleDefault;
    _borderColor = [UIColor whiteColor];
    _cornerLocation = CornerLoactionDefault;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _cornerWidth = 2.0;
    _backgroundAlpha = 0.5;
    _animationTimeInterval = 0.02;
    _scanningImageName = @"SGQRCode.bundle/QRCodeScanningLine";
    [self addSubview:self.titleL];
}

-(UILabel *)titleL
{
    if (!_titleL)
    {
        _titleL = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, kzWidth, 21.0f)];
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.font = [UIFont systemFontOfSize:16.0f];
        _titleL.textAlignment = NSTextAlignmentCenter;
    }
    return _titleL;
}

- (UIView *)contentView
{
    if (!_contentView)
    {
        CGFloat borderW = 0;
        CGFloat borderX = 0;
        CGFloat borderY = 0;
        if (IS_KIPHONE)
        {
            borderW = scanBorderW;
            borderX = scanBorderX;
            borderY = scanBorderY;
        }else
        {
            borderW = scanBorderW_ipad;
            borderX = scanBorderX_ipad;
            borderY = scanBorderY_ipad;
        }
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(borderX, borderY, borderW, borderW);
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

#pragma mark - - - 添加定时器
- (void)addTimer
{
    CGFloat scanninglineX = 0;
    CGFloat scanninglineY = 0;
    CGFloat scanninglineW = 0;
    CGFloat scanninglineH = 0;
    if (self.scanningAnimationStyle == ScanningAnimationStyleGrid)
    {
        [self addSubview:self.contentView];
        self.scanningline.image = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeScanningLineGrid"];
        [_contentView addSubview:self.scanningline];
        if (IS_KIPHONE)
        {
            scanninglineW = scanBorderW;
            scanninglineH = scanBorderW;
            scanninglineX = 0;
            scanninglineY = - scanBorderW;
        }else
        {
            scanninglineW = scanBorderW_ipad;
            scanninglineH = scanBorderW_ipad;
            scanninglineX = 0;
            scanninglineY = - scanBorderW_ipad;
        }
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);
    } else
    {
        [self addSubview:self.scanningline];
        if (IS_KIPHONE)
        {
            scanninglineW = scanBorderW;
            scanninglineH = 12;
            scanninglineX = scanBorderX;
            scanninglineY = scanBorderY;
        }else
        {
            scanninglineW = scanBorderW_ipad;
            scanninglineH = 12;
            scanninglineX = scanBorderX_ipad;
            scanninglineY = scanBorderY_ipad;
        }
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);
    }
    self.timer = [NSTimer timerWithTimeInterval:self.animationTimeInterval target:self selector:@selector(beginRefreshUI) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
#pragma mark - - - 移除定时器
- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self.scanningline removeFromSuperview];
    self.scanningline = nil;
}

#pragma mark - - - 执行定时器方法
- (void)beginRefreshUI
{
    __block CGRect frame = _scanningline.frame;
    static BOOL flag = YES;
    
    if (self.scanningAnimationStyle == ScanningAnimationStyleGrid)
    {
        if (flag)
        {
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                _scanningline.frame = frame;
            } completion:nil];
        } else
        {
            CGFloat scanBy = 0.0f;
            CGFloat scanByX = 0.0f;
            if (IS_KIPHONE)
            {
                scanBy = - scanBorderW;
                scanByX = scanBorderX;
            }else
            {
                scanBy =  - scanBorderW_ipad;
                scanByX = scanBorderX_ipad;
            }
            if (_scanningline.frame.origin.y >= scanBy)
            {
                CGFloat scanContent_MaxY = scanBy + kzWidth - 2 * scanByX;
                if (_scanningline.frame.origin.y >= scanContent_MaxY)
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        frame.origin.y = scanBy;
                        _scanningline.frame = frame;
                        flag = YES;
                    });
                } else
                {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        _scanningline.frame = frame;
                    } completion:nil];
                }
            } else
            {
                flag = !flag;
            }
        }
    } else
    {
        if (flag)
        {
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                _scanningline.frame = frame;
            } completion:nil];
        } else
        {
            CGFloat scanBy = 0.0f;
            if (IS_KIPHONE)
            {
                scanBy = scanBorderY;
            }else
            {
                scanBy = scanBorderY_ipad;
            }
            if (_scanningline.frame.origin.y >= scanBy)
            {
                CGFloat scanContent_MaxY = scanBy + kzHeight - 2 * scanBy;
                if (_scanningline.frame.origin.y >= scanContent_MaxY - 10)
                {
                    frame.origin.y = scanBy;
                    _scanningline.frame = frame;
                    flag = YES;
                } else
                {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        _scanningline.frame = frame;
                    } completion:nil];
                }
            } else
            {
                flag = !flag;
            }
        }
    }
}

- (UIImageView *)scanningline
{
    if (!_scanningline)
    {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:self.scanningImageName];
    }
    return _scanningline;
}

#pragma mark - - - set
- (void)setScanningAnimationStyle:(ScanningAnimationStyle)scanningAnimationStyle {
    _scanningAnimationStyle = scanningAnimationStyle;
}

- (void)setScanningImageName:(NSString *)scanningImageName {
    _scanningImageName = scanningImageName;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
}

- (void)setCornerLocation:(CornerLoaction)cornerLocation {
    _cornerLocation = cornerLocation;
}

- (void)setCornerColor:(UIColor *)cornerColor {
    _cornerColor = cornerColor;
}

- (void)setCornerWidth:(CGFloat)cornerWidth {
    _cornerWidth = cornerWidth;
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    _backgroundAlpha = backgroundAlpha;
}

- (void)setAnimationTimeInterval:(NSTimeInterval)animationTimeInterval {
    _animationTimeInterval = animationTimeInterval;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    /// 边框 frame
    CGFloat borderW = 0;
    CGFloat borderH = 0;
    CGFloat borderX = 0;
    CGFloat borderY = 0;
    CGFloat borderLineW = 0.2;
    
    if (IS_KIPHONE)
   {
       borderW = scanBorderW;
       borderH = borderW;
       borderX = scanBorderX;
       borderY = scanBorderY;
    }else
    {
        borderW = scanBorderW_ipad;
        borderH = borderW;
        borderX = scanBorderX_ipad;
        borderY = scanBorderY_ipad;
    }
    /// 空白区域设置
    [[[UIColor blackColor] colorWithAlphaComponent:self.backgroundAlpha] setFill];
    UIRectFill(rect);
    // 获取上下文，并设置混合模式 -> kCGBlendModeDestinationOut
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    // 设置空白区
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX + 0.5 * borderLineW, borderY + 0.5 *borderLineW, borderW - borderLineW, borderH - borderLineW)];
    [bezierPath fill];
    // 执行混合模式
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    /// 边框设置
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX, borderY, borderW, borderH)];
    borderPath.lineCapStyle = kCGLineCapButt;
    borderPath.lineWidth = borderLineW;
    [self.borderColor set];
    [borderPath stroke];
    
    
    CGFloat cornerLenght = 20;
    /// 左上角小图标
    UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
    leftTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    CGFloat insideExcess = fabs(0.5 * (self.cornerWidth - borderLineW));
    CGFloat outsideExcess = 0.5 * (borderLineW + self.cornerWidth);
    if (self.cornerLocation == CornerLoactionInside)
    {
        [leftTopPath moveToPoint:CGPointMake(borderX + insideExcess, borderY + cornerLenght + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside)
    {
        [leftTopPath moveToPoint:CGPointMake(borderX - outsideExcess, borderY + cornerLenght - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY - outsideExcess)];
    } else
    {
        [leftTopPath moveToPoint:CGPointMake(borderX, borderY + cornerLenght)];
        [leftTopPath addLineToPoint:CGPointMake(borderX, borderY)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght, borderY)];
    }
    
    [leftTopPath stroke];
    
    /// 左下角小图标
    UIBezierPath *leftBottomPath = [UIBezierPath bezierPath];
    leftBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside)
    {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - cornerLenght - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside)
    {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
    } else
    {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH - cornerLenght)];
    }
    
    [leftBottomPath stroke];
    
    /// 右上角小图标
    UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
    rightTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside)
    {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + cornerLenght + insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside)
    {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + cornerLenght - outsideExcess)];
    } else
    {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY + cornerLenght)];
    }
    
    [rightTopPath stroke];
    
    /// 右下角小图标
    UIBezierPath *rightBottomPath = [UIBezierPath bezierPath];
    rightBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside)
    {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - cornerLenght - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + borderH - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside)
    {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY + borderH + outsideExcess)];
    } else
    {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW, borderY + borderH - cornerLenght)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW, borderY + borderH)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY + borderH)];
    }
    
    [rightBottomPath stroke];
    
    
//    [[[UIColor blackColor]colorWithAlphaComponent:0.2]setFill];
//    
//    //半透明区域
//    UIRectFill(rect);
//    //透明区域
//    CGRect holeRect = CGRectMake((kzWidth - kHolewidth) / 2.0f, (kzHeight - kHoleheight) /2.0f, kHolewidth, kHoleheight);
//    
//    /** Intersection: 交集
//     CGRect CGRectIntersection(CGRect r1, CGRect r2)
//     返回交集部分rect
//     */
//    CGRect holeiInterSection = CGRectIntersection(holeRect, rect);
//    [[UIColor clearColor] setFill];
//    
//    //CGContextClearRect(ctx, <#CGRect rect#>)
//    //绘制
//    //CGContextDrawPath(ctx, kCGPathFillStroke);
//    UIRectFill(holeiInterSection);
    
}















@end
