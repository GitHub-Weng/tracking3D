//
//  BaseViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

-(id) getVCFromTabBarControllerByIndex:(NSInteger)index
{
    return [[WXTabBarController sharedInstance]getSuperVCByIndex:index];
}

@end
