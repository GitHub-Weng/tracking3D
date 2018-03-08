//
//  FrameProcessor.m
//  MinimumOpenCVLiveCamera
//
//  Created by Akira Iwaya on 2015/11/05.
//  Copyright © 2015年 akira108. All rights reserved.
//

#import "FrameProcessor.h"

@implementation FrameProcessor

- (instancetype)init
{
    // CT initialization
    box = cv::Rect(100,100,55,55);
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
    NSLog(@"position is (%d,%d)\n",box.x,box.y);
    // Draw small circle at the last point touched
    circle(frame, touch, 5, Scalar(0,255,0));
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
    
    touchBox = cv::Rect(x, y, 55, 55);
    touch = cv::Point(x, y);
}


// Reset the background subtraction object and the delay timer.
- (void)reset {
    pMOG2->~BackgroundSubtractor();   // necessary?
    pMOG2 = new BackgroundSubtractorMOG2(3, 100, false);  // (history, varThreshold, detectshadows)
    timeInSeconds = [[NSDate date] timeIntervalSince1970];
    delay = timeInSeconds + 4;
}

@end


