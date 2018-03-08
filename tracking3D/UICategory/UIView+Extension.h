//
//  UIView+Extension.h
//  QQKSong
//
//  Created by ethangao on 14-5-21.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

- (CGFloat)width;
- (CGFloat)height;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)bottom;
- (CGFloat)right;
- (CGFloat)top;
- (CGFloat)left;
- (CGFloat)centerX;
- (CGFloat)centerY;
- (CGSize)size;

- (void)setWidth:(CGFloat)newWidth;
- (void)setHeight:(CGFloat)newHeight;
- (void)setX:(CGFloat)newX;
- (void)setY:(CGFloat)newY;
- (void)setXY:(CGPoint)pt;

- (void)setBottom:(CGFloat)bottom;
- (void)setRight:(CGFloat)right;
- (void)setTop:(CGFloat)y;
- (void)setLeft:(CGFloat)x;
- (void)setSize:(CGSize)size;

- (void)setCenterX:(CGFloat)newCenterX;
- (void)setCenterY:(CGFloat)newCenterY;

// 调整anchorPoint时，要回到原位,不能偏离
- (void) setAnchorPoint:(CGPoint)anchorPoint;
// 移除所有的subview add by cyan
- (void)removeAllSubviews;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;
@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;
@property(nonatomic,readonly) CGRect screenFrame;

@end

