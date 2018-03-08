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



@end


