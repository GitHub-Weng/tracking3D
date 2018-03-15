//
//  Wrapper.m
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import "Wrapper.h"
#import "FrameProcessor.h"
#import "VideoSource.h"
#import "AudioController.h"
#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif


@interface Wrapper ()
@property(nonatomic, strong)FrameProcessor *frameProcessor;
@property(nonatomic, strong)VideoSource *videoSource;
@property(nonatomic, strong)AudioController *audioController;
@property(nonatomic, assign)NSInteger lastllap1DAction;//存储着利用LLAP检测出来的前一次1D运动,是上还是下运动
@property(nonatomic, assign)NSInteger lastllap1DActionMoveDepth;//存储着利用LLAP检测出来的前一次1D运动,是上还是下运动的深度
@property(nonatomic, assign)NSTimeInterval trackingTouchActionPassTime;

@end

@implementation Wrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frameProcessor = [[FrameProcessor alloc] init];
        _videoSource = [[VideoSource alloc] init];
        _videoSource.delegate = _frameProcessor;
        
        self.llap1DDistanceChange = 0;
        self.llap1DAction = 0;
        self.frame2DAction = 0;
        self.frame2DPosition = CGPointZero;
        self.lastllap1DAction = TTANoneClick;
        
        self.tracking3DAction = T3DStill;
        self.trackingTouchAction = TTANoneClick;
        
        
        self.audioController = [AudioController sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useOpenCVDection) name:@"FrameProcessor_UseOpenCVDetection" object:nil];//使用OpenCV检测运动的方向
        
        //检测运动的具体距离
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateMouse) name:@"FrameProcessor_UpdateMouse" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useLLAPDetection) name:@"AudioController_UseLLAPDetection" object:nil];
        

    }
    return self;
}

- (void)setTargetView:(UIView *)view {
    self.videoSource.targetView = view;
}

- (void)switchMode:(int)mode {
    [self.videoSource switchMode:mode];
}

- (void)updateBox:(CGPoint)coords {
    [self.videoSource update:coords];
}

- (void)start {
    [self.videoSource start];
}

- (void)stop {
    [self.videoSource stop];
}

-(void)switchCamera{
    [self.videoSource switchCamera];
}



+ (id)sharedInstance {
    
    static dispatch_once_t once;
    
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];});
    
    return sharedInstance;
}
//上下左右测试没有问题
-(void)useOpenCVDection{
    
    self.frame2DAction = self.frameProcessor.frame2DAction;
    self.frame2DPosition = [self.frameProcessor getOpenCVCurrentPosition];
    
//action detection
//    if(frame2DAction & T3DLeft){
//       // NSLog(@"move left");
//    }
//    if(frame2DAction & T3DRight){
//      //  NSLog(@"move right");
//    }
//    if(frame2DAction & T3DFront){
//      //  NSLog(@"move front");
//    }
//    if(frame2DAction & T3DBack){
//       // NSLog(@"move back");
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseOpenCVDetection object:nil];
    
}
//LLAP检测结果，如果动作的振幅超过一定程度才会调用这个函数
- (void)useLLAPDetection
{
    self.llap1DAction = [self.audioController getLLAP1DAction];
    self.lastllap1DActionMoveDepth = self.llap1DDistanceChange;
    
    [self touchActionDetection];
    
    self.llap1DDistanceChange = [self.audioController getllap1DActionDistanceChange];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_TrackingTouchAction object:nil];
    
//action detection
//    if(llap1DAction & LLAP1DDown){
//        NSLog(@"move down %d mm\n",(int)self.llapDectionDistanceChange);
//    }
//    if(llap1DAction & LLAP1DUp){
//        NSLog(@"move up %d mm\n",(int)self.llapDectionDistanceChange);
//    }

}
- (void)UpdateMouse{
    
    
}
- (TrackingTouchAction)trackTouchAction
{
    return TTANoneClick;
}
- (Tracking3DAction)track3DAction{
    
    return T3DStill;
}

-(void)touchActionDetection{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseLLAPDetection_Up_Down object:nil];
    
    //若上一次的运动是向上运动，那么可以判断是否为点击，双击还是向下长按事件
    if(self.lastllap1DAction & LLAP1DDown){
        
        if(self.llap1DAction & LLAP1DUp){//单击事件，判断是否有双击事件
            self.trackingTouchAction = TTASingleClick;//上一次往下运动，这次往上运动，记录为一次单击
            self.lastllap1DAction = LLAP1DStill;
            
            //如果检测到了之前点击时间是单击，根据时间判断是不是双击动作
                NSDate* date = [NSDate date];
                NSTimeInterval interval = [date timeIntervalSince1970] - self.trackingTouchActionPassTime;
                
                if(interval < 3){
                    self.trackingTouchAction = TTADoubleClick;
                    self.lastllap1DAction = LLAP1DStill;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseLLAPDetection object:nil];
                    return;
                }
                else{

                    [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseLLAPDetection object:nil];
                    NSDate* date = [NSDate date];
                    self.trackingTouchActionPassTime = [date timeIntervalSince1970];
                    return;
                }
    
            
        }
        
        if(self.llap1DAction & LLAP1DDown){//按下事件，判断是否为长按向下事件，若是还要记录长按向下的深度
            self.trackingTouchAction = TTALongPressDown;
            self.lastllap1DAction = LLAP1DStill;
            [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseLLAPDetection object:nil];
            self.longPressDepth = self.longPressDepth + self.lastllap1DActionMoveDepth;
            return;
        }
        else{
            self.longPressDepth = 0;
        }
        
    }
    //若上一次的运动是向上运动，那么可以判断是否为向上长按事件
    if(self.lastllap1DAction & LLAP1DUp){
        if(self.llap1DAction & LLAP1DUp){
            self.trackingTouchAction = TTALongPressUp;
            self.lastllap1DAction = LLAP1DStill;
            [[NSNotificationCenter defaultCenter] postNotificationName:Wrapper_UseLLAPDetection object:nil];
            self.longPressDepth = self.longPressDepth + self.lastllap1DActionMoveDepth;
            return;
        }
    }
    self.lastllap1DAction = self.llap1DAction;
    return;
}

//先把实现模拟点击鼠标的功能给实现，点击，双击，往下长按，往上长提动作的模拟。

@end
