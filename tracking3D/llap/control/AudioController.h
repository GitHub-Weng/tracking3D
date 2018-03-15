//
//  AudioController.h
//  llap
//
//  Created by Wei Wang on 2/18/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <mach/mach_time.h>

//Record sample rate
#define AUDIO_SAMPLE_RATE   48000
//Start audio frequency
#define START_FREQ          17500.0
//Frequency interval
#define FREQ_INTERVAL       350.0
//Number of frequency
#define NUM_FREQ            8
//Number of frame size
#define MAX_FRAME_SIZE      1920
//Send socket
#define SEND_SOCKET_DATA    0
//Socket size
#define SOCKET_SIZE         2048
//Write log
#define WRITE_LOG           0
//Speed adjust
#define SPEED_ADJ           1.5

#if WRITE_LOG
#define DebugLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

#else
#define DebugLog(...)

#endif

typedef NS_ENUM(NSInteger, LLAP1DAction) {//表示帧处理过程中的2D运动方向
    LLAP1DStill    = 0,
    LLAP1DUp       = 1<<5,
    LLAP1DDown     = 1<<6,
};
@interface AudioController : NSObject <NSStreamDelegate>

@property Float32 audiodistance;
- (OSStatus) startIOUnit;
- (OSStatus) stopIOUnit;
- (void) playMySound;
- (void) stopMySound;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;
+ (void) switchRecordingMicPhone;
+ (id)sharedInstance;
- (float)getDistanceChange;
- (float)getDistanceChangeSum;
-(NSInteger)getLLAP1DAction;//判断动作是向上还是向下
-(float)getllap1DActionDistanceChange;//获取这个上下运动的距离变化
@end
