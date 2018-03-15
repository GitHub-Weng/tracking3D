//
//  BaseViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "BaseViewController.h"
@interface BaseViewController ()
@property(nonatomic,strong)UIView* myBackgroundView;
@end

@implementation BaseViewController

-(id) getVCFromTabBarControllerByIndex:(NSInteger)index
{
    return [[WXTabBarController sharedInstance]getSuperVCByIndex:index];
}
-(void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    //self.navigationController?.setNavigationBarHidden(true, animated: animated)
}
-(instancetype)init{
    CGFloat offsetY = 44+[[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat subHeight = 48 ;
    if(IsIPhoneX){
        subHeight = 83;
    }
    if(self = [super init]){
        self.myBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, offsetY, SCREEN_WIDTH, SCREEN_HEIGHT - subHeight - offsetY)];
        [self.view addSubview:self.myBackgroundView];
        [self.view sendSubviewToBack:self.myBackgroundView];
       
        
    }
    return self;
}
-(void)setMyBackgroundViewImage:(NSString *)myBackgroundViewImageName{
    if(myBackgroundViewImageName){
        UIImage* backgroundImage = [UIImage imageNamed:myBackgroundViewImageName];
        self.myBackgroundView.layer.contents = (__bridge id)backgroundImage.CGImage;
    }else{
        return;
    }

}
-(void)setMyBackgroundViewBGColor:(UIColor *)myBackgroundBGColor{
    self.myBackgroundView.backgroundColor = myBackgroundBGColor;
}

@end
