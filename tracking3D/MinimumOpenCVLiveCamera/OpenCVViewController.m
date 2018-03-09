//
//  ViewController.m
//  llap
//
//  Created by Ke Sun on 5/18/17.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "OpenCVViewController.h"
#import "LLAPViewController.h"
#import "Wrapper.h"

@interface OpenCVViewController (){
   // AudioController *audioController;
}

@property (strong,nonatomic) UIButton* start;
@property (strong,nonatomic) UIButton* stop;
@property (strong,nonatomic) UIButton* mode;
@property (strong,nonatomic) UIButton* mouse;
@property (strong,nonatomic) UIButton* testOpenCVTrackResultBtn;
@property (strong,nonatomic) UIButton* switchCameraBtn;
@property (strong,nonatomic) UIView* previewView;
@property (strong,nonatomic) Wrapper* wrapper;
@property (assign,nonatomic) BOOL canTestOpenCVTrackResult;
@end

@implementation OpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //audioController = [[AudioController alloc] init];

     float btnWidth = SCREEN_WIDTH * 0.2;
     float btnHeight = btnWidth/2;
     float btnMargin = btnHeight;
    
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH ,SCREEN_HEIGHT)];
    self.wrapper = [[Wrapper alloc]init];
    
    self.start = [[UIButton alloc]initWithFrame:CGRectMake(btnMargin, SCREEN_HEIGHT/2+100, btnWidth, btnHeight)];
    [self.start addTarget:self action:@selector(startTracking) forControlEvents:UIControlEventTouchDown];
    
    self.stop = [[UIButton alloc]initWithFrame:CGRectMake(self.start.right + btnMargin, SCREEN_HEIGHT/2+100, btnWidth,btnHeight)];
    [self.stop addTarget:self action:@selector(stopTracking) forControlEvents:UIControlEventTouchDown];
    
    self.mode = [[UIButton alloc]initWithFrame:CGRectMake(self.stop.right+btnMargin, SCREEN_HEIGHT/2+100, btnWidth,btnHeight)];
    [self.mode addTarget:self action:@selector(showAlertMenu) forControlEvents:UIControlEventTouchDown];
    
    self.mouse = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 55,55)];
    [self.mouse addTarget:self action:@selector(showAlertMenu) forControlEvents:UIControlEventTouchDown];
    
    self.testOpenCVTrackResultBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2, SCREEN_HEIGHT/2+200, btnWidth,btnWidth)];
    [self.testOpenCVTrackResultBtn addTarget:self action:@selector(showTestOpenCVResult) forControlEvents:UIControlEventTouchDown];
    
    self.switchCameraBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 80, 40,40)];
    [self.switchCameraBtn setImage:[UIImage imageNamed:@"switch_camera.png"] forState:UIControlStateNormal];
    [self.switchCameraBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchDown];
    
    
    self.start.layer.cornerRadius = 4;
    self.stop.layer.cornerRadius = 4;
    self.mode.layer.cornerRadius = 4;
    self.testOpenCVTrackResultBtn.layer.cornerRadius = btnWidth/2;
    
    self.start.backgroundColor = [UIColor grayColor];
    self.stop.backgroundColor = [UIColor grayColor];
    self.mode.backgroundColor = [UIColor grayColor];
    self.mouse.backgroundColor = [UIColor grayColor];
    self.testOpenCVTrackResultBtn.backgroundColor = [UIColor grayColor];
    
    [self.start setTitle:@"start" forState:UIControlStateNormal];
    [self.start setTintColor:[UIColor whiteColor]];
    
    [self.stop setTitle:@"stop" forState:UIControlStateNormal];
    [self.stop setTintColor:[UIColor whiteColor]];
    
    [self.mode setTitle:@"mode" forState:UIControlStateNormal];
    [self.mode setTintColor:[UIColor whiteColor]];
    
    [self.mouse setTitle:@"mouse" forState:UIControlStateNormal];
    [self.mouse setTintColor:[UIColor whiteColor]];
    
    [self.testOpenCVTrackResultBtn setTitle:@"test" forState:UIControlStateNormal];
    [self.testOpenCVTrackResultBtn setTintColor:[UIColor whiteColor]];

    
    [self.wrapper setTargetView:self.previewView];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.start];
    [self.view addSubview: self.stop];
    [self.view addSubview:self.mode];
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.mouse];
    [self.view addSubview:self.testOpenCVTrackResultBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performOpenCVPositionUpdate:) name:@"OpenCVPositionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performCanUseLLAPUpdate:) name:@"canUseLLAPUpdate" object:nil];
}

//这里加了TabBarController的功能之后切换tabBar并不会调用这个方法
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    if(touch){
        CGPoint position = [touch locationInView:self.view];
        [self.wrapper updateBox:position];
        NSLog(@"touch position is (%f,%f)",position.x,position.y);
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    if(touch){
        CGPoint position = [touch locationInView:self.view];
        [self.wrapper updateBox:position];
        NSLog(@"touch position is (%f,%f)",position.x,position.y);
    }
}
-(void)startTracking{
    [self.wrapper start];

    //[audioController startIOUnit];
}
-(void)stopTracking{
    [self.wrapper stop];
    
    //[audioController startIOUnit];
}
-(void)switchCamera{
    [self.wrapper switchCamera];
}

//
//@IBAction func switchMode(_ sender: Any) {
//    wrapper.stop()
//    showAlertMenu()
//}
//
//@IBAction func touchStart(_ sender: Any) {
//    wrapper.start()
//    audioController.startIOUnit();
//}
//
//@IBAction func touchStop(_ sender: Any) {
//    wrapper.stop()
//    audioController.stopIOUnit();
//}

-(void)showAlertMenu{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Mode" message:@"Choose a mode" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* touch = [UIAlertAction actionWithTitle:@"Touch Tracking" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wrapper switchMode:1];
        [self.wrapper start];
    }];
    
    UIAlertAction* objectDet = [UIAlertAction actionWithTitle:@"Object Detection" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wrapper switchMode:2];
        [self.wrapper start];
    }];
    
    UIAlertAction* objectDetMask = [UIAlertAction actionWithTitle:@"Object Detection Mask" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wrapper switchMode:3];
        [self.wrapper start];
    }];
    
    UIAlertAction* opticalFlow = [UIAlertAction actionWithTitle:@"Optical Flow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wrapper switchMode:4];
        [self.wrapper start];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.wrapper start];
    }];
    
    [alertController addAction:touch];
    [alertController addAction:objectDet];
    [alertController addAction:objectDetMask];
    [alertController addAction:opticalFlow];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)showTestOpenCVResult{
    if(self.canTestOpenCVTrackResult){
        self.mouse.hidden = YES;
        self.canTestOpenCVTrackResult = NO;
    }else{
        self.mouse.hidden = NO;
        self.canTestOpenCVTrackResult = YES;
    }
}
//
//func showAlertMenu() {
//
//    let alertController = UIAlertController(title: "Mode", message: "Choose a mode", preferredStyle: UIAlertControllerStyle.alert)
//
//    let touch = UIAlertAction(title: "touch tracking", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.wrapper.switchMode(1)
//        self.wrapper.start()
//    }
//    let objectDet = UIAlertAction(title: "object detection", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.showAlertMsg(mode: 2)
//    }
//    let objectDetMask = UIAlertAction(title: "object detection mask", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.showAlertMsg(mode: 3)
//    }
//    let opticalFlow = UIAlertAction(title: "optical flow", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.showAlertMsg(mode: 4)
//    }
//    let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.wrapper.start()
//    }
//
//    alertController.addAction(touch)
//    alertController.addAction(objectDet)
//    alertController.addAction(objectDetMask)
//    alertController.addAction(opticalFlow)
//    alertController.addAction(cancel)
//    self.present(alertController, animated: true, completion: nil)
//}
//
//func showAlertMsg(mode: integer_t) {
//
//    let alertController = UIAlertController(title: "Detection Mode", message: "Keep the camera still! Place your device on a steady surface.", preferredStyle: UIAlertControllerStyle.alert)
//
//    let okAction = UIAlertAction(title: "Got it!", style: UIAlertActionStyle.default) {
//        (result : UIAlertAction) -> Void in
//        self.wrapper.switchMode(mode)
//        self.wrapper.start()
//    }
//
//    alertController.addAction(okAction)
//    self.present(alertController, animated: true, completion: nil)
//}
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)performDisUpdate:(NSNotification *)notification
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//    int tempdis=(int) audioController.audiodistance/DISPLAY_SCALE;
//
//     _slider.value=(audioController.audiodistance-DISPLAY_SCALE*tempdis)/DISPLAY_SCALE;
//    }
//        );
//
//}

- (void)performOpenCVPositionUpdate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGPoint openCVCurrentPosition = [self.wrapper getOpenCVCurrentPosition];
        self.mouse.frame = CGRectMake(openCVCurrentPosition.x, openCVCurrentPosition.y, SCREEN_WIDTH/8, SCREEN_WIDTH/8);
        
    }
                   );
    
}
- (void)performCanUseLLAPUpdate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.mouse.backgroundColor == [UIColor grayColor]){
            self.mouse.backgroundColor = [UIColor redColor];
        }else{
            self.mouse.backgroundColor = [UIColor grayColor];
        }
        
    }
                   );
    
}


@end

