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

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

@interface Wrapper ()
@property(nonatomic, strong)FrameProcessor *frameProcessor;
@property(nonatomic, strong)VideoSource *videoSource;
@end

@implementation Wrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frameProcessor = [[FrameProcessor alloc] init];
        _videoSource = [[VideoSource alloc] init];
        _videoSource.delegate = _frameProcessor;
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

-(CGPoint)getOpenCVCurrentPosition{
    return [self.frameProcessor getOpenCVCurrentPosition];
}
@end
