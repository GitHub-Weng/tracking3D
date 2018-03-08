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
@interface BaseViewController : UIViewController
-(id) getVCFromTabBarControllerByIndex:(NSInteger)index;
@end
