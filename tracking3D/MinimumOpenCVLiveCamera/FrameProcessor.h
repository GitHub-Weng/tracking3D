//
//  FrameProcessor.h
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoSource.h"
#import "CompressiveTracker.h"
#include <iostream>

using namespace cv;

typedef NS_ENUM(NSInteger, Frame2DAction) {//表示帧处理过程中的2D运动方向
    F2DStill    = 0,
    F2DLeft     = 1<<1,
    F2DRight    = 1<<2,
    F2DFront    = 1<<3,
    F2DBack     = 1<<4,
};

@interface FrameProcessor : NSObject<VideoSourceDelegate> {
    
    // CT framework
    CompressiveTracker ct;
    
    cv::Rect box;       // tracking box
    cv::Rect touchBox;  // touch box location
    
    Mat current_gray;
    
    // Farneback optical flow
    Mat flow;
    Mat flowMat, prevgray;
    
    // MOG2 Background subtractor
    Mat fgMaskMOG2;
    Ptr<BackgroundSubtractor> pMOG2;
    
    NSTimeInterval timeInSeconds;
    NSTimeInterval delay;
    
    // touch signal
    bool touched;
    cv::Point touch;
}

-(CGPoint)getOpenCVCurrentPosition;
@property NSInteger frame2DAction;
@end


