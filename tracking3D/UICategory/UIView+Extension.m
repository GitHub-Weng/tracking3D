//
//  UIView+Extension.m
//  QQKSong
//
//  Created by ethangao on 14-5-21.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (CGFloat)width
{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height
{
    return CGRectGetHeight(self.frame);
}

- (CGFloat)x
{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)y
{
    return CGRectGetMinY(self.frame);
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)right
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)top
{
    return CGRectGetMinY(self.frame);
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}
- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}



- (CGFloat)centerX
{
    return self.center.x;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)newWidth
{
    self.frame = CGRectMake(self.x, self.y, newWidth, self.height);
}

- (void)setHeight:(CGFloat)newHeight
{
    self.frame = CGRectMake(self.x, self.y, self.width, newHeight);
}

- (void)setX:(CGFloat)newX
{
    self.frame = CGRectMake(newX, self.y, self.width, self.height);
}

- (void)setCenterX:(CGFloat)newCenterX
{
    self.center = CGPointMake(newCenterX, self.center.y);
}


- (void)setY:(CGFloat)newY
{
    self.frame = CGRectMake(self.x, newY, self.width, self.height);
}

- (void)setCenterY:(CGFloat)newCenterY
{
    self.center = CGPointMake(self.center.x, newCenterY);
}


- (void)setXY:(CGPoint)pt
{
    self.frame = CGRectMake(pt.x, pt.y, self.width, self.height);
}

- (CGFloat)screenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.x;
    }
    return x;
}

- (CGFloat)screenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}

- (CGFloat)screenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.x;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}

- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.y;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}



- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    self.center = CGPointMake(self.center.x - transition.x, self.center.y - transition.y);
}



- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

- (void)removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end

