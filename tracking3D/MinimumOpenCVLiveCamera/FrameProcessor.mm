//
//  FrameProcessor.m
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import "FrameProcessor.h"
#import "CommonMacros.h"
typedef NS_ENUM(NSInteger, mAVCaptureDevicePosition) {
    AVCaptureDevicePositionUnspecified = 0,
    AVCaptureDevicePositionBack        = 1,
    AVCaptureDevicePositionFront       = 2,
};

/*
    Here Thr_X is the threshold value for positionX,if the change of the positionX > Thr_X,
    mean the object move obviously in X axis,in which situation we can not use the LLAP.
 */
static float Thr_X = SCREEN_WIDTH/10;
static float Thr_Y = SCREEN_WIDTH/10;
static float Thr_XT3D = 30;//这是用于动作的
static float Thr_YT3D = 30;

@interface FrameProcessor ()
@property CGPoint openCVCurrentPosition;
@property CGPoint openCVPriorPosition;
@property float boxWidth;
@property float constX;
@property float constY;
@property float deltaX;
@property float deltaY;

@property bool moveLeft;
@property bool moveRight;
@property bool moveFront;
@property bool moveBack;

@property bool notFirstFrame;
@end

@implementation FrameProcessor

- (instancetype)init
{
    self.notFirstFrame = NO;
    self.boxWidth = [self calculateBoxWidth];
    self.constX = SCREEN_WIDTH/(355.0-125.0);
    self.constY = SCREEN_HEIGHT/(580.0-80.0);
    self.frame2DAction = F2DStill;
    
    // CT initialization
    box = cv::Rect(100,100,self.boxWidth,self.boxWidth);
    ct.init(current_gray, box);
    
    // Background subtraction object
    pMOG2 = new BackgroundSubtractorMOG2();
    
    // Touch signals
    touched = false;
    touch = cv::Point(0,0);
    
    return self;
}


// Process each frame in touch mode. Uses the compressive
// tracker to predict where the object is in the current frame, then
// draws a bounding box around the object. Listens for signals when
// the user has touched the screen, requesting a window location change.

- (void)touchMode:(Mat &)frame {
    
    cvtColor(frame, current_gray, CV_RGB2GRAY);
    
    // Update the tracking box to touched point. This check is necessary to account for
    // multiple threads are running for frame processing and touch actions.
    if(touched)
    {
        box = touchBox;
        touched = false;
    }
    // Process Frame
    ct.processFrame(current_gray, box);
    // Draw bounding box
    rectangle(frame, box, Scalar(0,0,255));
    //NSLog(@"position is (%d,%d)\n",box.y,box.x);
    // Draw small circle at the last point touched
    circle(frame, touch, 5, Scalar(0,255,0));
    
    self.openCVPriorPosition = CGPointMake(self.openCVCurrentPosition.x, self.openCVCurrentPosition.y);
    self.openCVCurrentPosition = CGPointMake(box.y, box.x);
    
    //这里虽然可以直接放返回box的位置，但是位置不准，要进行校正
    CGFloat openCVCurrentPositionX;
    CGFloat openCVCurrentPositionY;

    openCVCurrentPositionX = box.y;
    openCVCurrentPositionY = box.x;

    /*Here we should translate the box's position to the position on iphone screen,
      so that we can get the coarse position for 2D tracking
     A ---- B
      |    |
      |    |
      |    |
     C ---- D
     if we use the front camera,here the reference point is point A
     if we use the back camera,here the reference point is point B
     
     For example, if we use the front camera
     According to the result, when the box move,
     the range change in iphone is around A(125,80) B(355,80) C(125,580) D(355,580)
    
     so we can get the coarse positon on iphone by these point,
     the formula to tranform the box position into position on iphone are
     
      iphoneX = (boxX - 125.0)/(355-125.0)*SCREEN_WIDTH;
      iphoneY = (boxY - 80.0)/(580-80.0)*SCREEN_HEIGHT;
     
     Here we mark the (355-125.0)*SCREEN_WIDTH as constX,(580-80.0)*SCREEN_HEIGHT as constY,
     as for constX, we replace the /(355-125.0)*SCREEN_WIDTH as *SCREEN_WIDTH/(355-125.0),
     we do the same for constY.
     
     */
    
    if(openCVCurrentPositionX>125 &&openCVCurrentPositionX <355){
        openCVCurrentPositionX = (openCVCurrentPositionX - 125.0)*self.constX;
    }else{
        openCVCurrentPositionX = -100;
    }
    
    if(openCVCurrentPositionY>80 &&openCVCurrentPositionY <580){
        openCVCurrentPositionY = (openCVCurrentPositionY - 80.0)*self.constY;
    }else{
        openCVCurrentPositionY = -100;
    }

    if([VideoSource currentChoseCameraPosition] == AVCaptureDevicePositionBack){
        openCVCurrentPositionX = SCREEN_WIDTH - openCVCurrentPositionX - SCREEN_WIDTH/8;
    }
    self.openCVCurrentPosition = CGPointMake(openCVCurrentPositionX, openCVCurrentPositionY);
   
    if(self.notFirstFrame){//if is not the first frame,which means we can calculate the change between the frames
        float changeX = self.openCVCurrentPosition.x - self.openCVPriorPosition.x;
        float changeY = self.openCVCurrentPosition.y - self.openCVPriorPosition.y;
        
        //EMAtoday=α * Pricetoday + ( 1 - α ) * EMAyesterday;
        //其中，α为平滑指数，一般取作2/(N+1)。在计算MACD指标时，EMA计算中的N一般选取12和26天，因此α相应为2/13和2/27。
        //这里暂时不用EMA来算变化趋势，直接用变化累计值
        
        self.deltaX = self.deltaX + changeX;
        self.deltaY = self.deltaY + changeY;
        
        if(fabsf(self.deltaX) > Thr_X || fabsf(self.deltaY) > Thr_Y){//这个是所有动作检测的基础，如果在二维上移动的幅度太小了，就认为没有运动
            self.frame2DAction = F2DStill;
            
            if(fabsf(self.deltaX) > fabsf(self.deltaY))
            {
                if(fabsf(self.deltaX) > Thr_X)
                {
                    if(self.deltaX > 0)
                    {
                        self.frame2DAction = self.frame2DAction | F2DRight;
                    }
                    else
                    {
                        self.frame2DAction = self.frame2DAction | F2DLeft;
                    }
                }
            }
            else{
                if(fabsf(self.deltaY) > Thr_Y)
                {
                    if(self.deltaY > 0)
                    {
                        self.frame2DAction = self.frame2DAction | F2DBack;
                    }
                    else
                    {
                        self.frame2DAction = self.frame2DAction | F2DFront;
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FrameProcessor_UseOpenCVDetection" object:nil];
            self.deltaX = 0;
            self.deltaY = 0;
        }
        
    }

    self.notFirstFrame = YES;
}


// Detect and track objects using background subtraction. The complete
// algorithm can be found in the accompanying report.
- (void)detectionMode:(Mat &)frame {
    
    // wait for camera to adjust before continuing after brief delay
    if([[NSDate date] timeIntervalSince1970] < delay)
        return;
    
    Mat current;
    frame.copyTo(current);   // replace frame with mask

    
    // Apply a slight blur before updating the backgound model; then
    // reduce the resolution by resizing the image matrix twice, first to a
    // smaller size, then back to the original size.
    blur(current, current, cv::Size(7,7));
    pMOG2->operator()(current, fgMaskMOG2);
    resize(fgMaskMOG2, fgMaskMOG2, cv::Size(106, 80), 0, 0, INTER_CUBIC);   // compress image
    resize(fgMaskMOG2, fgMaskMOG2, cv::Size(640, 480), 0, 0);      // return to original size
    
    // Detect all contours in the mask
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    double size;
    
    findContours(fgMaskMOG2.clone(), contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    size = contours.size();
    
    // Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point>> contours_poly(size);
    vector<cv::Rect> boundRect;
    Mat output;
    const int minArea = 400;
    int i;
    
    for(i = 0; i < size; ++i)
    {
        approxPolyDP(Mat(contours[i]), contours_poly[i], 3, true);
        cv::Rect temp = boundingRect(Mat(contours_poly[i]));
        boundRect.push_back(temp);
        boundRect.push_back(temp);
        // push twice to ensure non-overlapping rectangle appear
        // at least once after they are grouped
    }
    
    groupRectangles(boundRect, 1, 0.2);  // merge grouped rectangles
    
    // Draw rectangles around each contour greater than the minimum area
    for(i = 0; i < boundRect.size(); ++i)
    {
        if(boundRect[i].area() > minArea)
            rectangle(frame, boundRect[i].tl(), boundRect[i].br(), Scalar(0,0,255), 2);
    }
}


// Same as detetion mode, but the original frame is replaced with the MOG2 mask.
- (void)detectionModeMask:(Mat &)frame {
    
    // wait for camera to adjust before continuing after brief delay
    if([[NSDate date] timeIntervalSince1970] < delay)
        return;
    

    // update backgound model
    blur(frame, frame, cv::Size(7,7));
    pMOG2->operator()(frame, fgMaskMOG2);
    resize(fgMaskMOG2, fgMaskMOG2, cv::Size(106, 80), 0, 0, INTER_CUBIC);   // compress image
    resize(fgMaskMOG2, fgMaskMOG2, cv::Size(640, 480), 0, 0);
    
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    double size;
    
    findContours(fgMaskMOG2.clone(), contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    size = contours.size();
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point>> contours_poly(size);
    vector<cv::Rect> boundRect;
    Mat output = fgMaskMOG2;
    const int minArea = 400;
    int i;
    
    for(i = 0; i < size; ++i)
    {
        approxPolyDP(Mat(contours[i]), contours_poly[i], 3, true);
        cv::Rect temp = boundingRect(Mat(contours_poly[i]));
        boundRect.push_back(temp);
        boundRect.push_back(temp);
    }
    
    groupRectangles(boundRect, 1, 0.2);   // merge grouped rectangles
    
    cvtColor(fgMaskMOG2, output, CV_GRAY2RGB);   // convert mask back to rgb
    
    // Draw rectangles around each contour greater than the minimum area
    for(i = 0; i < boundRect.size(); ++i)
    {
        if(boundRect[i].area() > minArea)
            rectangle(output, boundRect[i].tl(), boundRect[i].br(), Scalar(0,255,0), 2);
    }
    
    output.copyTo(frame);   // replace frame with mask
}


// Optical flow frame processing using Farneback's algorithm
// Source code by Vlada Kucera
// http://funvision.blogspot.dk/2016/02/opencv-31-tutorial-optical-flow.html
- (void)farneback:(Mat &)frame {
    
    Mat original;
    Mat img;
    
    frame.copyTo(original);   // update previous frame as the current one
    
    cvtColor(original, original, COLOR_BGR2GRAY);
    
    if (prevgray.empty() == false ) {
        
        // calculate optical flow
        calcOpticalFlowFarneback(prevgray, original, flowMat, 0.4, 1, 12, 2, 8, 1.2, 0);
        // copy Umat container to standard Mat
        flowMat.copyTo(flow);
        
        // By y += 5, x += 5 you can specify the grid
        for (int y = 0; y < frame.rows; y += 5) {
            for (int x = 0; x < frame.cols; x += 5)
            {
                // get the flow from y, x position * 10 for better visibility
                const Point2f flowatxy = flow.at<Point2f>(y, x) * 10;
                // draw line at flow direction
                line(frame, cv::Point(x, y), cv::Point(cvRound(x + flowatxy.x), cvRound(y + flowatxy.y)), Scalar(255,0,0));
                // draw initial point
                circle(frame, cv::Point(x, y), 1, Scalar(0, 0, 0), -1);
            }
        }
        
        // fill previous image again
        original.copyTo(prevgray);
        
    }
    else {
        // fill previous image in case prevgray.empty() == true
        original.copyTo(prevgray);
    }
}

/*
 设备                        设计分辨率(点)
 iPhone4/4s                 320 x 480
 iPhone5/5s/5c/SE           320 x 568
 iPhone6/6s/7               375 x 667
 iPhone6P/6sP/7P            414 x 736
 iphoneX                    375 × 812
 */

/* Update the tracking box location where the screen was touched
   Translate iphone 6 screen coordinates to OpenCV mat coordinates.
   This translation is not entirely accurate yet. Work in progress.

  iPhone          Mat          |  iPhone      Mat
    __          ________       | 0,0__         __0,0
   |  |        |        |      |   |  |       |  |
   |  |667     |        |480   |   |  |y      |  |x
   |__|        |________|      |   |__|       |__|
   375            640          |    x          y
 
 */
- (void)update:(CGPoint)coords {
    
    touched = true;
    float ratiox = (583.0/640.0);
    float ratioy = (375.0/423.0);
    float x1 = coords.y * ratiox;
    float y1 = coords.x * ratioy;
    int x = x1;
    int y = 400 - y1;
    
    touchBox = cv::Rect(x, y, self.boxWidth,self.boxWidth);
    touch = cv::Point(x, y);
}


// Reset the background subtraction object and the delay timer.
- (void)reset {
    pMOG2->~BackgroundSubtractor();   // necessary?
    pMOG2 = new BackgroundSubtractorMOG2(3, 100, false);  // (history, varThreshold, detectshadows)
    timeInSeconds = [[NSDate date] timeIntervalSince1970];
    delay = timeInSeconds + 4;
}

-(CGPoint)getOpenCVCurrentPosition{
    return self.openCVCurrentPosition;
}

-(NSInteger)calculateBoxWidth{
    return SCREEN_WIDTH/10.0;
}

@end


