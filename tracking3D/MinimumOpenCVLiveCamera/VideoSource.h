//
//  VideoSource.h
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

@protocol VideoSourceDelegate<NSObject>

- (void)touchMode:(cv::Mat &)frame;
- (void)detectionMode:(cv::Mat &)frame;
- (void)detectionModeMask:(cv::Mat &)frame;
- (void)farneback:(cv::Mat &)frame;
- (void)update:(CGPoint)coords;
- (void)reset;

@end

@interface VideoSource : NSObject {
    
    int tmode;
}

- (void)switchMode:(int)mode;
- (void)update:(CGPoint)coords;
- (void)start;
- (void)stop;


@property(nonatomic, weak) id<VideoSourceDelegate> delegate;
@property(nonatomic, strong) UIView *targetView;

@end

