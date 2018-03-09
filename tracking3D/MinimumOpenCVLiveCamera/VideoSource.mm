//
//  VideoSource.m
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import "VideoSource.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

using namespace cv;
using namespace std;
static NSInteger choseCameraPosition = 0;

@interface VideoSource () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) CALayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput* captureDeviceInput;
@property (strong, nonatomic) AVCaptureVideoDataOutput* captureDeviceOutput;

@end


@implementation VideoSource

- (void)setTargetView:(UIView *)targetView {
    if (self.previewLayer == nil) {
        return;
    }
    [targetView.layer addSublayer:self.previewLayer];
    self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    self.previewLayer.frame = targetView.bounds;
    self.previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI / 2);
    //M_PI + M_PI/2 这种情况下横屏是上下正常，但是左右相反，竖屏是上下相反，但是左右正常
    //M_PI/2        这种情况下横屏是左右相反，但是上下正常，竖屏是上下正常，但是左右相反

}

- (AVCaptureDevice *)cameraWithPostion:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession* deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];

    NSArray *devicesIOS  = deviceDiscoverySession.devices;
    for (AVCaptureDevice *device in devicesIOS) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)switchCamera{
    
    AVCaptureDevicePosition position;
    
    AVCaptureDevice *newDevice;
    if(choseCameraPosition == AVCaptureDevicePositionFront){
        position = AVCaptureDevicePositionBack;
    }else{
        position = AVCaptureDevicePositionFront;
    }
    
    choseCameraPosition = position;
    
    AVCaptureDeviceDiscoverySession* deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    
    NSArray *devicesIOS  = deviceDiscoverySession.devices;
    for (AVCaptureDevice *device in devicesIOS) {
        if ([device position] == position) {
            newDevice = device;
        }
    }
    
    NSError *error = nil;
    [self.captureSession stopRunning];
    [self.captureSession removeInput:self.captureDeviceInput];
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:newDevice error:&error];
    
    if([self.captureSession canAddInput:self.captureDeviceInput]){
        [self.captureSession addInput:self.captureDeviceInput];
        [self.captureSession startRunning];
    }
   

}

//- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for ( AVCaptureDevice *device in devices )
//        if ( device.position == position ) return device;
//    return nil;
//}


- (instancetype)init
{
    self = [super init];
    if (self) {
        choseCameraPosition = AVCaptureDevicePositionFront;
        self.captureSession = [[AVCaptureSession alloc] init];
        
        //这里就是为什么Mat的规格为640*480
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        device = [self cameraWithPostion:AVCaptureDevicePositionFront];
       
        
        NSError *error = nil;
        self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if([self.captureSession canAddInput:self.captureDeviceInput]){
             [self.captureSession addInput:self.captureDeviceInput];
        }
       
        
        self.captureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.captureDeviceOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
        self.captureDeviceOutput.alwaysDiscardsLateVideoFrames = YES;//here default is YES
        if([self.captureSession canAddOutput:self.captureDeviceOutput]){
            [self.captureSession addOutput:self.captureDeviceOutput];
        }
        
        
        dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
        [self.captureDeviceOutput setSampleBufferDelegate:self queue:queue];
        
        self.previewLayer = [CALayer layer];
        
        tmode = true;
    }
    
    return self;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *base;
    int width, height, bytesPerRow;
    base = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    width = (int)CVPixelBufferGetWidth(imageBuffer);
    height = (int)CVPixelBufferGetHeight(imageBuffer);
    bytesPerRow = (int)CVPixelBufferGetBytesPerRow(imageBuffer);
    
    Mat mat = Mat(height, width, CV_8UC4, base);
    Mat mat2 = Mat(height, width, CV_8UC4, base);
    
    //Processing here
    switch(tmode)
    {
        case 1:
            [self.delegate touchMode:mat];
            break;
        case 2:
            [self.delegate detectionMode:mat];
            break;
        case 3:
            [self.delegate detectionModeMask:mat];
            break;
        case 4:
            [self.delegate farneback:mat];
            break;
        default:
            [self.delegate touchMode:mat];
            break;
    }
    
    CGImageRef imageRef;
    //前置摄像头的时候需要这样需改，不然视图会奇怪
    if(choseCameraPosition == AVCaptureDevicePositionFront){
        cv::flip(mat, mat2, 0);
        imageRef = [self CGImageFromCVMat:mat2];
    }else{
        imageRef = [self CGImageFromCVMat:mat];
    }
   
   
    dispatch_sync(dispatch_get_main_queue(), ^{
       self.previewLayer.contents = (__bridge id)imageRef;
    });
    
    CGImageRelease(imageRef);
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
}

- (void)switchMode:(int)mode {
    tmode = mode;
    [self.delegate reset];
}

- (void)update:(CGPoint)coords {
    if(tmode == 1){
        //we should adjust the position of the touch point when use the Front Camera
        if(choseCameraPosition == AVCaptureDevicePositionFront){
            coords = CGPointMake( CGRectGetWidth([[UIScreen mainScreen] bounds]) - coords.x, coords.y);
        }
        [self.delegate update:coords];
    }
    
}

- (void)start {
    [self.captureSession startRunning];
}

- (void)stop {
    [self.captureSession stopRunning];
}

- (CGImageRef)CGImageFromCVMat:(Mat)cvMat {
    if (cvMat.elemSize() == 4) {
        cv::cvtColor(cvMat, cvMat, COLOR_BGRA2RGBA);
    }
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}

+(NSInteger)currentChoseCameraPosition{
    return choseCameraPosition;
}

@end
