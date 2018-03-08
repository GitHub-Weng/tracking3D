//
//  WXTabBarController.h
//  WXTabBarController
//
//  Created by leichunfeng on 15/11/20.
//  Copyright © 2015年 leichunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

typedef enum tabBarTag {
    OneDimension,
    Visualized,
    TwoDimension
} tabBarTag;

@interface WXTabBarController : UITabBarController <UITabBarControllerDelegate>
+ (id)sharedInstance;
-(id)getSuperVCByIndex:(NSInteger)VCIndex;
@end
