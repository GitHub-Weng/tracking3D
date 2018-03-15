//
//  AudioController.m
//  llap
//
//  Created by Wei Wang on 2/18/16.
//  Copyright © 2016 Nanjing University. All rights reserved.
//
#import <Accelerate/Accelerate.h>
#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>

// Utility file includes
#import "CAXException.h"
#import "CAStreamBasicDescription.h"

#include "RangeFinder.h"
/*
    define the threshold value for the action for move up and down,
    if the distance change is bigger than 5mm，then the object had moved
 */
#define Thr_Up_Down 6
#define Thr_Sample 16
//the threshold value for sample num，
//这里如果静止不动的话LLAP的距离变化也会一直增加，观察到如果手运动的话，那么20个数据以上的变化是同向的，静止则没有连续那么多
static NSInteger llap1DAction;//using the LLAP method to detect the action of the moving object
static Float32   llap1DActionDistanceChange;
struct CallbackData {
    AudioUnit               rioUnit;
    RangeFinder*            rangeFinder;
    BOOL*                   audioChainIsBeingReconstructed;
    BOOL                    canSendData;
    NSOutputStream*         dataOutStream;
    UInt64                  mtime;
    UInt64                  mUIUpdateTime;
    AVAudioPlayer*          audioPlayer;  //for soundplay remove clickss
    Float32                 distance;
    Float32                 distanceChange;//实时距离变化
    Float32                 distanceChangeSum;//实时距离变化的和的累计
    Float32                 delta;//distance change sum
    NSInteger               sampleNumForThr_Sample;
    bool                    positiveSample;
    
    CallbackData(): rioUnit(NULL), rangeFinder(NULL) , audioChainIsBeingReconstructed(NULL), canSendData(false), dataOutStream(NULL), mtime(0),mUIUpdateTime(0),audioPlayer(NULL),distance(0) {}
} cd;


static OSStatus	performRender (void                         *inRefCon,
                               AudioUnitRenderActionFlags 	*ioActionFlags,
                               const AudioTimeStamp 		*inTimeStamp,
                               UInt32 						inBusNumber,
                               UInt32 						inNumberFrames,
                               AudioBufferList              *ioData)
{
    int16_t*    recorddata;
    Float32     distancechange;
    OSStatus err = noErr;
    if (*cd.audioChainIsBeingReconstructed == NO)
    {
        cd.sampleNumForThr_Sample++;
        mach_timebase_info_data_t info;
        if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
        UInt64 startTime = mach_absolute_time();
        
        
        // we are calling AudioUnitRender on the input bus of AURemoteIO
        // this will store the audio data captured by the microphone in ioData
        err = AudioUnitRender(cd.rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
        
        recorddata= (int16_t*) ioData->mBuffers[0].mData;
        
        
        //Copy recorddata to RangeFinder buffer
        
        memcpy((void*) cd.rangeFinder->GetRecDataBuffer(inNumberFrames), (void*) ioData->mBuffers[0].mData, sizeof(int16_t)*inNumberFrames);
        
        // Get the distance back
        distancechange = cd.rangeFinder->GetDistanceChange();
        cd.distanceChange = distancechange;
        cd.distanceChangeSum += distancechange;
        cd.distance=cd.distance+distancechange*SPEED_ADJ;
        
        //printf("cd.distance change %f\n",distancechange);
        //printf("cd.distance %f\n",cd.distance);

        cd.delta = cd.delta + distancechange;
        
        
        /*这里需要16个连续数据的符号相同才可以采用，如果不这样的话会出现这样的情况，
         当没有物体在手机前面的时候动作探测一直是上，或者手放在手机上方不动，这个时候也是，
         根本原因是上方没有物体或者物体静止的时候距离变化还是会不断增加。但是这两种情况不能再16个连续数据下距离变化符号保持一致。*/
        bool sampleSignalChange = cd.positiveSample;
        if(distancechange > 0){
            cd.positiveSample = YES;
        }else{
            cd.positiveSample = NO;
        }
        if(sampleSignalChange != cd.positiveSample){//说明符号改变了
            if(cd.sampleNumForThr_Sample < Thr_Sample){//表明这段数据不能用于移动物体，而是静态造成的
                cd.delta = 0;
                cd.sampleNumForThr_Sample = 0;
            }else
            {
                llap1DActionDistanceChange = fabsf(cd.delta);
                //printf("cd.delta is %f\n",cd.delta);
                llap1DAction = LLAP1DStill;
                if(cd.delta > 0){
                    llap1DAction = llap1DAction | LLAP1DUp;
                    printf("UP\n");
                }else{
                    llap1DAction = llap1DAction | LLAP1DDown;
                    printf("Down\n");
                }
                cd.delta = 0;
                cd.sampleNumForThr_Sample = 0;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioController_UseLLAPDetection" object:nil];
            }
        }
        if(cd.distance<0)
        {cd.distance=0;
        }
        if(cd.distance>500)
        {
            cd.distance=500;
        }
        
        memcpy((void*) ioData->mBuffers[0].mData, (void*) cd.rangeFinder->GetPlayBuffer(inNumberFrames), sizeof(int16_t)*inNumberFrames);
        
        if(cd.canSendData&&SEND_SOCKET_DATA)
        {
            if(cd.rangeFinder->mSocBufPos>0)
            {
                long len=(cd.rangeFinder->mSocBufPos+1>=SOCKET_SIZE) ? SOCKET_SIZE : cd.rangeFinder->mSocBufPos+1;
                uint8_t buf[len];
                memcpy(buf,cd.rangeFinder->GetSocketBuffer(), len);
                len=[cd.dataOutStream write:(const uint8_t*)buf maxLength:len];
                cd.rangeFinder->AdvanceSocketBuffer(len);
            }
        }
        
        cd.mtime=startTime;
        
        if(fabs(distancechange)>0.06&& (startTime-cd.mUIUpdateTime)/1.0e6*info.numer/info.denom>10)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioController_AudioDisUpdate" object:nil];
            cd.mUIUpdateTime=startTime;
        }
        
    }
    
    return err;
}



@interface AudioController(){
    AudioUnit       _myioUnit;
    RangeFinder*    _myRangeFinder;
    BOOL            _audioChainIsBeingReconstructed;
}
- (void)setupAudioSession;
- (void)setupIOUnit;
- (void)setupAudioChain;
@property float moveDistanceChange;
@end

@implementation AudioController

- (instancetype) init
{
    self = [super init];
    if(self)
    {   _myRangeFinder = NULL;
        [self setupAudioChain];
        [AudioController switchRecordingMicPhone];
    }
    
    return self;
}

@synthesize audiodistance = _audiodistance;

- (void) setAudiodistance:(Float32) d
{
    _audiodistance=d;
    cd.distance=d;
}


- (Float32) audiodistance
{
    _audiodistance=cd.distance;
    return cd.distance;
}

#pragma mark-

- (void)handleInterruption:(NSNotification *)notification
{   DebugLog(@"Interruption");
    try {
        UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
        DebugLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
        
        if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
            [self stopIOUnit];
            //[self stopMySound];
        }
        
        if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
            // make sure to activate the session
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (nil != error) DebugLog(@"AVAudioSession set active failed with error: %@", error);
            
            //[self startIOUnit];
            
        }
    } catch (CAXException e) {
        fprintf(stderr, "Error: %s \n", e.mOperation);
    }
}


- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    DebugLog(@"Route change:");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            DebugLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            DebugLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            DebugLog(@"     CategoryChange");
            DebugLog(@" New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            DebugLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            DebugLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            DebugLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            DebugLog(@"     ReasonUnknown");
    }
    
    DebugLog(@"Previous route:\n");
    DebugLog(@"%@", routeDescription);
}

- (void)handleMediaServerReset:(NSNotification *)notification
{
    DebugLog(@"Media server has reset");
    _audioChainIsBeingReconstructed = YES;
    
    usleep(25000); //wait here for some time to ensure that we don't delete these objects while they are being accessed elsewhere
    
    // rebuild the audio chain
    delete _myRangeFinder;      _myRangeFinder = NULL;
    
    [self setupAudioChain];
    //[self startIOUnit];
    
    _audioChainIsBeingReconstructed = NO;
}


#pragma mark-


- (void)setupAudioSession
{
    try {
        // Configure the audio session
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission granted");
            }
            else {
                NSLog(@"Permission denied");
            }
        }];
        // we are going to play and record so we pick that category
        NSError *error = nil;
//        [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord  error:&error];//AVAudioSessionCategoryPlayAndRecord
////
           [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];//AVAudioSessionCategoryPlayAndRecord
        
        
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        XThrowIfError((OSStatus)error.code, "couldn't set session's audio category");
        
        // set the buffer duration to 10 ms
        NSTimeInterval bufferDuration = .01;
        [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's I/O buffer duration");
        
        // set the session's sample rate
        [sessionInstance setPreferredSampleRate:AUDIO_SAMPLE_RATE error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session's preferred sample rate");
        
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];
        
        // we don't do anything special in the route change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:sessionInstance];
        
        // if media services are reset, we need to rebuild our audio chain
        [[NSNotificationCenter defaultCenter]	addObserver:	self
                                                 selector:	@selector(handleMediaServerReset:)
                                                     name:	AVAudioSessionMediaServicesWereResetNotification
                                                   object:	sessionInstance];
        
        // activate the audio session
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        XThrowIfError((OSStatus)error.code, "couldn't set session active");
        
    }
    
    catch (CAXException &e) {
        DebugLog(@"Error returned from setupAudioSession: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        DebugLog(@"Unknown error returned from setupAudioSession");
    }
    
    return;
}




- (void)setupIOUnit
{
    try {
        // Create a new instance of AURemoteIO
        
        AudioComponentDescription desc;
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;
        
        AudioComponent comp = AudioComponentFindNext(NULL, &desc);
        XThrowIfError(AudioComponentInstanceNew(comp, &_myioUnit), "couldn't create a new instance of AURemoteIO");
        
        //  Enable input and output on AURemoteIO
        //  Input is enabled on the input scope of the input element
        //  Output is enabled on the output scope of the output element
        
        UInt32 one = 1;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "could not enable input on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, sizeof(one)), "could not enable output on AURemoteIO");
        
        // Explicitly set the input and output client formats
        // sample rate = 44100, num channels = 1, format = 16 bit Int
        
        CAStreamBasicDescription ioFormat = CAStreamBasicDescription(AUDIO_SAMPLE_RATE, 1, CAStreamBasicDescription::kPCMFormatInt16, false);
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &ioFormat, sizeof(ioFormat)), "couldn't set the input client format on AURemoteIO");
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &ioFormat, sizeof(ioFormat)), "couldn't set the output client format on AURemoteIO");
        
        // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
        // of samples it will be asked to produce on any single given call to AudioUnitRender
        UInt32 maxFramesPerSlice = MAX_FRAME_SIZE;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32)), "couldn't set max frames per slice on AURemoteIO");
        
        // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
        UInt32 propSize = sizeof(UInt32);
        XThrowIfError(AudioUnitGetProperty(_myioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize), "couldn't get max frames per slice on AURemoteIO");
        DebugLog(@"frame per slice %d",maxFramesPerSlice);
        _myRangeFinder = new RangeFinder(maxFramesPerSlice, NUM_FREQ, START_FREQ, FREQ_INTERVAL);
        
        // We need references to certain data in the render callback
        // This simple struct is used to hold that information
        
        cd.rioUnit = _myioUnit;
        cd.rangeFinder = _myRangeFinder;
        cd.audioChainIsBeingReconstructed = &_audioChainIsBeingReconstructed;
        
        // Set the render callback on AURemoteIO
        AURenderCallbackStruct renderCallback;
        renderCallback.inputProc = performRender;
        renderCallback.inputProcRefCon = NULL;
        XThrowIfError(AudioUnitSetProperty(_myioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, sizeof(renderCallback)), "couldn't set render callback on AURemoteIO");
        
        // Initialize the AURemoteIO instance
        XThrowIfError(AudioUnitInitialize(_myioUnit), "couldn't initialize AURemoteIO instance");
    }
    
    catch (CAXException &e) {
        DebugLog(@"Error returned from setupIOUnit: %d: %s", (int)e.mError, e.mOperation);
    }
    catch (...) {
        DebugLog(@"Unknown error returned from setupIOUnit");
    }
    
    return;
}


- (void)setupAudioChain
{
    [self setupAudioSession];
    [self setupIOUnit];
    if(SEND_SOCKET_DATA)
        [self setupNetwork];
    [self setupAudioPlayer];
    [AudioController switchRecordingMicPhone];
}

#pragma mark-

-(void) setupAudioPlayer
{
    NSError *error;
    //Add background music
    //CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFStringRef([[NSBundle mainBundle] pathForResource:@"background" ofType:@"m4a"]), kCFURLPOSIXPathStyle, false);
    //cd.audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:(__bridge NSURL*)url error:&error];
    
    if(error!=nil)
    {
        XThrowIfError((OSStatus)error.code, "couldn't create AVAudioPlayer");
    }
    else{
        [cd.audioPlayer setNumberOfLoops: -1];
    }
    [cd.audioPlayer setVolume:0.01];
    //CFRelease(url);
}

-(void) playMySound
{
    [cd.audioPlayer play];
}

-(void) stopMySound
{
    [cd.audioPlayer stop];
}

#pragma mark-

- (void) setupNetwork
{
    if(!cd.dataOutStream)
    {
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef) CFSTR("192.168.1.5"), 12345, NULL, &writeStream);
        
        cd.dataOutStream = (__bridge_transfer NSOutputStream *)writeStream;
        [cd.dataOutStream setDelegate:self];
        
        [cd.dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [cd.dataOutStream open];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            if(SEND_SOCKET_DATA)
            {
                if(cd.rangeFinder->mSocBufPos>0)
                {
                    long len=(cd.rangeFinder->mSocBufPos+1>=SOCKET_SIZE) ? SOCKET_SIZE : cd.rangeFinder->mSocBufPos+1;
                    uint8_t buf[len];
                    memcpy(buf,cd.rangeFinder->GetSocketBuffer(), len);
                    len=[cd.dataOutStream write:(const uint8_t*)buf maxLength:len];
                    cd.rangeFinder->AdvanceSocketBuffer(len);
                    cd.canSendData=false;
                }
                else
                {
                    cd.canSendData=true;
                }
            }
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            
            [cd.dataOutStream close];
            [cd.dataOutStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                        forMode:NSDefaultRunLoopMode];
            cd.dataOutStream = nil; // oStream is instance variable
            break;
        }
            
            
    }
    
}

#pragma mark-
- (OSStatus)startIOUnit
{
    
    OSStatus err = AudioOutputUnitStart(_myioUnit);
    return err;
}

- (OSStatus)stopIOUnit
{
    OSStatus err = AudioOutputUnitStop(_myioUnit);
    return err;
}

#pragma mark-

- (void) dealloc
{
    delete _myRangeFinder;      _myRangeFinder = NULL;
    [self stopMySound];
    if(cd.dataOutStream)
    {   [cd.dataOutStream close];
        [cd.dataOutStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSDefaultRunLoopMode];
        cd.dataOutStream = nil;
    }
    
}


//切换录音的麦克风，这里主要是顶部以及底部的切换，注意顶部的是front不是top
+ (void) switchRecordingMicPhone
{
    NSError* theError = nil;
    BOOL result = YES;

    NSArray* inputs = [[AVAudioSession sharedInstance] availableInputs];
    
    // Locate the Port corresponding to the built-in microphone.
    AVAudioSessionPortDescription* builtInMicPort = nil;
    for (AVAudioSessionPortDescription* port in inputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic])
        {
            builtInMicPort = port;
            break;
        }
    }
    
    //NSLog(@"%@", builtInMicPort.dataSources);
    
    AVAudioSessionDataSourceDescription* inputDataSource = nil;
    
    for (AVAudioSessionDataSourceDescription* source in builtInMicPort.dataSources)
    {
        if ([source.orientation isEqual:AVAudioSessionOrientationFront])
        {
            inputDataSource = source;
            break;
        }
    } // end data source iteration
    
    if (inputDataSource)
    {
        NSLog(@"Currently selected source is \"%@\" for port \"%@\"", builtInMicPort.selectedDataSource.dataSourceName, builtInMicPort.portName);
        NSLog(@"Attempting to select source \"%@\" on port \"%@\"", inputDataSource, builtInMicPort.portName);
        
        //Set a preference for the front data source.
        
        theError = nil;
        result = [builtInMicPort setPreferredDataSource:inputDataSource error:&theError];
        if (!result)
        {
            // an error occurred. Handle it!
            //NSLog(@"setPreferredDataSource failed");
        }
    }
    
    // Make sure the built-in mic is selected for input. This will be a no-op if the built-in mic is
    // already the current input Port.
    theError = nil;
    result = [[AVAudioSession sharedInstance] setPreferredInput:builtInMicPort error:&theError];
    if (!result)
    {
        // an error occurred. Handle it!
        //NSLog(@"setPreferredInput failed");
    }
    
}
+ (id)sharedInstance {
    
    static dispatch_once_t once;
    
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];});
    
    return sharedInstance;
}

//这个返回的检测出上下运动的时候记录的距离变化
-(float)getllap1DDetectionDistanceChange{
    return cd.delta;
}

//这个返回的是实时的距离变化，频率很快
-(float)getDistanceChange{
    return cd.distanceChange;
}

-(float)getDistanceChangeSum{
    return cd.distanceChangeSum;
}

-(NSInteger)getLLAP1DAction{
    return llap1DAction;
}

-(float)getllap1DActionDistanceChange{
    return llap1DActionDistanceChange;
}
@end
