/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The app's main view controller. 
 */

#import <SceneKit/SceneKit.h>
#import "AAPLGameViewController.h"
#import "AAPLGameController.h"
#import "Wrapper.h"
#import "AudioController.h"
#import "WXTabBarController.h"
@interface AAPLGameViewController ()
@property(nonatomic, assign)NSInteger frame2DAction;//存储着利用OpenCV检测出来的2D运动，表示平面上的前后左右
@property(nonatomic, assign)NSInteger lastframe2DAction;//存储着利用OpenCV检测出来的2D运动，表示平面上的前后左右
@property (readonly) SCNView *gameView;
@property (strong, nonatomic) AAPLGameController *gameController;
@property (strong, nonatomic) Wrapper *wrapper;
@property (strong, nonatomic) UIView *mouse;//模拟鼠标，这里为了不影响游戏体验用一个小红点模拟
@property(strong,nonatomic)NSTimer* timer;
@property(assign,nonatomic)BOOL haveJump;//表示刚刚跳
@end

@implementation AAPLGameViewController

- (SCNView *)gameView {
    return (SCNView *)self.view.subviews[0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wrapper = [Wrapper sharedInstance];
    self.mouse = [[UIView alloc]initWithFrame:CGRectMake(-100, -100, 5, 5)];
    self.mouse.backgroundColor = [UIColor redColor];
    // 1.3x on iPads
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.gameView.contentScaleFactor = MIN(1.3, self.gameView.contentScaleFactor);
        self.gameView.preferredFramesPerSecond = 60.0;
    }
    
    
    self.gameController = [[AAPLGameController alloc] initWithSCNView:self.gameView];
    
    // Configure the view
    self.gameView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.mouse];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(controllerNoJump) userInfo:nil repeats:-1];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performWXTabBarControllerIndexChange) name:WXTabBarControllerIndexChange object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.timer invalidate];
    self.timer = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(controllerNoJump) userInfo:nil repeats:-1];
}
-(void)performWXTabBarControllerIndexChange{
    if([[WXTabBarController sharedInstance] getCurIndex]==3){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performMovingUpdate) name:Wrapper_UseOpenCVDetection object:nil];
        
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performWrapper_UseLLAPDetection) name:Wrapper_UseLLAPDetection object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performWrapper_UseLLAPDetection_Up_Down) name:Wrapper_UseLLAPDetection_Up_Down object:nil];
       
    }else{
        [[NSNotificationCenter defaultCenter]removeObserver:self name:Wrapper_UseOpenCVDetection object:nil];
        //[[NSNotificationCenter defaultCenter]removeObserver:self name:Wrapper_UseLLAPDetection object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:Wrapper_UseLLAPDetection_Up_Down object:nil];
    }

}

-(void)performMovingUpdate
{
    CGPoint point = self.wrapper.frame2DPosition;
    self.frame2DAction = self.wrapper.frame2DAction;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.mouse.frame = CGRectMake(point.x, point.y, 5, 5);
        //NSLog(@"isMutul---%d",isMutul); 有交互返回1   没重叠 返回0
    }
                   );
//    if(self.mouse.x < SCREEN_WIDTH/5)
//    {
//        [self.gameController setCharacterDirection:(vector_float2){-0.5, 0}];
//    }
//
//    if(self.mouse.x > SCREEN_WIDTH*0.8)
//    {
//        [self.gameController setCharacterDirection:(vector_float2){0.5, 0}];
//        return;
//    }
//
//    if(self.mouse.x < SCREEN_HEIGHT/5)
//    {
//        [self.gameController setCharacterDirection:(vector_float2){0, -0.5}];
//        return;
//    }
//
//    if(self.mouse.x > SCREEN_HEIGHT*0.8)
//    {
//        [self.gameController setCharacterDirection:(vector_float2){0, 0.5}];
//        return;
//    }
//
    if((self.frame2DAction & T3DFront))
    {
        [self.gameController setCharacterDirection:(vector_float2){0, -0.4}];
        //self.frame2DAction = T3DStill;
        return;
    }
    if((self.frame2DAction & T3DBack))
    {
        [self.gameController setCharacterDirection:(vector_float2){0, 0.4}];
        //self.frame2DAction = T3DStill;
        return;
    }
    
    if((self.frame2DAction & T3DLeft))
    {
        [self.gameController setCharacterDirection:(vector_float2){-0.4, 0}];
        ///self.frame2DAction = T3DStill;
        return;
    }
    if((self.frame2DAction & T3DRight))
    {
        [self.gameController setCharacterDirection:(vector_float2){0.4, 0}];
        //self.frame2DAction = T3DStill;
        return;
    }

}
-(void)performWrapper_UseLLAPDetection_Up_Down{

        if(self.wrapper.llap1DAction & LLAP1DUp){
            [self.gameController controllerJump:YES];
            self.haveJump = YES;
            //return;
        }
        if(self.wrapper.llap1DAction & LLAP1DDown){
            [self.gameController controllerAttack];
            //return;
        }
}
-(void)controllerNoJump{
    if(!self.haveJump){
        return;
    }
    [self.gameController controllerJump:NO];
    self.haveJump = NO;
    
    if((self.frame2DAction & T3DFront))
    {
        [self.gameController setCharacterDirection:(vector_float2){0, -0.4}];
        return;
    }
    if((self.frame2DAction & T3DBack))
    {
        [self.gameController setCharacterDirection:(vector_float2){0, 0.4}];
        return;
    }
    
    if((self.frame2DAction & T3DLeft))
    {
        [self.gameController setCharacterDirection:(vector_float2){-0.4, 0}];
        return;
    }
    if((self.frame2DAction & T3DRight))
    {
        [self.gameController setCharacterDirection:(vector_float2){0.4, 0}];
        return;
    }
}
//-(void)performWrapper_UseLLAPDetection{
//
//    if(self.wrapper.trackingTouchAction == TTALongPressUp){
//        [self.gameController controllerJump:YES];
//        self.haveJump = YES;
//    }
//    if(self.wrapper.trackingTouchAction == TTALongPressDown){
//        [self.gameController controllerAttack];
//
//    }
//
//    if(self.wrapper.llap1DAction & LLAP1DDown){
//        [self.gameController controllerAttack];
//    }
//    if(self.wrapper.llap1DAction & LLAP1DUp){
//        [self.gameController controllerJump:YES];
//        self.haveJump = YES;
//    }
//}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
