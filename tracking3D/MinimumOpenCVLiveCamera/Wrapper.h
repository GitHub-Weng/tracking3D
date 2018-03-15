//
//  Wrapper.h
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Wrapper_UseOpenCVDetection @"Wrapper_UseOpenCVDetection"//使用openCV检测二维运动的情况完成时发出的通知
#define Wrapper_UseLLAPDetection @"Wrapper_UseLLAPDetection"//使用LLAP检测一维运动的情况完成时发出的通知
#define Wrapper_UseLLAPDetection_Up_Down @"Wrapper_UseLLAPDetection_Up_Down"//使用LLAP检测上下运动变化情况完成时发出的通知

#define Wrapper_TrackingTouchAction @"Wrapper_TrackingTouchAction"//使用

typedef NS_ENUM(NSInteger, TrackingTouchAction) {//代表利用LLAP检测出来的模拟触摸动作，点击，双击，往下长按，往上长提
    TTANoneClick = 1,
    TTASingleClick,
    TTADoubleClick,
    TTALongPressDown,
    TTALongPressUp,
};

typedef NS_ENUM(NSInteger, Tracking3DAction) {//表示结合LLAP以及OpenCV检测出来的在3D上的动作，代表上下左右前后
    T3DStill    = 0,

    T3DLeft     = 1<<1,
    T3DRight    = 1<<2,
    T3DFront    = 1<<3,
    T3DBack     = 1<<4,
    T3DUp       = 1<<5,
    T3DDown     = 1<<6,
};
@interface Wrapper : NSObject

- (void)setTargetView:(UIView *)view;
- (void)switchMode:(int)mode;
- (void)updateBox:(CGPoint)coords;
- (void)start;
- (void)stop;
- (void)switchCamera;

+ (id)sharedInstance;
- (Tracking3DAction)track3DAction;
- (TrackingTouchAction)trackTouchAction;

@property(nonatomic, assign)CGPoint frame2DPosition;
@property(nonatomic, assign)float llap1DDistanceChange;//单位是mm，代表着使用LLAP在一维上测出的距离变化，这里的一维只的是上下运动
@property(nonatomic, assign)NSInteger frame2DAction;//存储着利用OpenCV检测出来的2D运动，表示平面上的前后左右
@property(nonatomic, assign)NSInteger llap1DAction;//存储着利用LLAP检测出来的1D运动，表示上下运动

@property(nonatomic, assign)NSInteger tracking3DAction;//wrapper包装好的3D追踪结果，可以测量上下左右前后运动
@property(nonatomic, assign)NSInteger trackingTouchAction;//wrapper包装好的触摸动作检测，可以测量点击，双击，往下长按，往上长按
@property(nonatomic, assign)NSInteger longPressDepth;//记录长按的深度
@end
