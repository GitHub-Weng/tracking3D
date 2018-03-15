//
//  TrackingButton.h
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 12/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackingButton : UIButton
- (instancetype)initWithFrame:(CGRect)frame;
-(void)setImage:(UIImage *)image forState:(UIControlState)state;
-(void)setAppNameLabelText:(NSString*)appName;

@end
