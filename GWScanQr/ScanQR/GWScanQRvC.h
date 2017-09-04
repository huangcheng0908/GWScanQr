//
//  GWScanQRvC.h
//  ZTCallLinPhone
//
//  Created by MacBook on 2017/9/4.
//  Copyright © 2017年 2017 ABB Genway Xiamen Electrical Equipment Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, CornerLoaction)
{
    /// 默认与边框线同中心点
    CornerLoactionDefault,
    /// 在边框线内部
    CornerLoactionInside,
    /// 在边框线外部
    CornerLoactionOutside,
};

typedef NS_ENUM(NSInteger,ScanningAnimationStyle)
{
    /// 单线扫描样式
    ScanningAnimationStyleDefault,
    /// 网格扫描样式
    ScanningAnimationStyleGrid,
};

@interface GWScanQRvC : UIView

/**
 扫描文字提示
 */
@property (retain,nonatomic)UILabel * titleL;

/**
 扫描样式，默认 ScanningAnimationStyleDefault
 */
@property (nonatomic, assign) ScanningAnimationStyle scanningAnimationStyle;

/**
 扫描区周边颜色的 alpha 值，默认 0.2f
 */
@property (nonatomic, assign) CGFloat backgroundAlpha;

/**
 边框颜色，默认白色
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 边角颜色，默认微信颜色
 */
@property (nonatomic, strong) UIColor *cornerColor;

/**
 边角宽度，默认 2.f
 */
@property (nonatomic, assign) CGFloat cornerWidth;

/**
 边角位置，默认 CornerLoactionDefault
 */
@property (nonatomic, assign) CornerLoaction cornerLocation;

/**
 扫描线动画时间，默认 0.02
 */
@property (nonatomic, assign) NSTimeInterval animationTimeInterval;

/**
 扫描线名
 */
@property (nonatomic, copy) NSString *scanningImageName;

/**
 扫描文本
 */
@property (nonatomic, strong) UIView *contentView;

/**
 定时器
 */
@property (nonatomic, strong) NSTimer *timer;

/**
 扫描线
 */
@property (nonatomic, strong) UIImageView *scanningline;

/**
 添加定时器
 */
- (void)addTimer;

/**
 移除定时器
 */
- (void)removeTimer;





@end
