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

@interface VideoSource () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) CALayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
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
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _captureSession = [[AVCaptureSession alloc] init];
        
        //这里就是为什么Mat的规格为640*480
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        
      // AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        //AVCaptureDevice* device = [self cameraWithPosition:AVCaptureDevicePositionFront];
       
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        [_captureSession addInput:input];
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
        output.alwaysDiscardsLateVideoFrames = YES;
        [_captureSession addOutput:output];
        
        dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
        [output setSampleBufferDelegate:self queue:queue];
        
        _previewLayer = [CALayer layer];
        
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
    
    CGImageRef imageRef = [self CGImageFromCVMat:mat];
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
    if(tmode == 1)
       [self.delegate update:coords];
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


@end
