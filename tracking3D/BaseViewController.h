//
//  BaseViewController.h
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXTabBarController.h"
#import "AudioController.h"
#import "CommonMacros.h"
#import "UIView+Extension.h"
#import "CommonMethod.h"

@interface BaseViewController : UIViewController
-(id) getVCFromTabBarControllerByIndex:(NSInteger)index;
-(void)setMyBackgroundViewImage:(NSString *)myBackgroundViewImageName;
-(void)setMyBackgroundViewBGColor:(UIColor *)myBackgroundBGColor;
@end
