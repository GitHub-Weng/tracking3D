//
//  ViewController.m
//  llap
//
//  Created by Ke Sun on 5/18/17.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "OpenCVViewController.h"
#import "LLAPViewController.h"
#import "UIView+Extension.h"
#import "Wrapper.h"


static float btnWidth = 100;
static float btnHeight = 50;
static float btnMargin = 50;

@interface OpenCVViewController (){
   // AudioController *audioController;
}

@property (strong,nonatomic) UIButton* start;
@property (strong,nonatomic) UIButton* stop;
@property (strong,nonatomic) UIButton* mode;
@property (strong,nonatomic) UIView* previewView;
@property (strong,nonatomic) Wrapper* wrapper;
@end

@implementation OpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //audioController = [[AudioController alloc] init];

    
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH ,SCREEN_HEIGHT)];
    self.wrapper = [[Wrapper alloc]init];
    self.start = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH- 3*btnWidth - 2*btnMargin)/2, 500, btnWidth, btnHeight)];
    
    [self.start addTarget:self action:@selector(startTracking) forControlEvents:UIControlEventTouchDown];
    self.stop = [[UIButton alloc]initWithFrame:CGRectMake(self.start.right + btnMargin, 500, btnWidth,btnHeight)];
    
    [self.stop addTarget:self action:@selector(stopTracking) forControlEvents:UIControlEventTouchDown];
    
    
    self.mode = [[UIButton alloc]initWithFrame:CGRectMake(self.stop.right+btnMargin, 500, btnWidth,btnHeight)];
    
    
    
    self.start.layer.cornerRadius = 4;
    self.stop.layer.cornerRadius = 4;
    self.mode.layer.cornerRadius = 4;
    
    self.start.backgroundColor = [UIColor grayColor];
    self.stop.backgroundColor = [UIColor grayColor];
    self.mode.backgroundColor = [UIColor grayColor];
    
    
    [self.start setTitle:@"start" forState:UIControlStateNormal];
    [self.start setTintColor:[UIColor whiteColor]];
    
    
    [self.stop setTitle:@"stop" forState:UIControlStateNormal];
    [self.stop setTintColor:[UIColor whiteColor]];
    
    
    [self.mode setTitle:@"mode" forState:UIControlStateNormal];
    [self.mode setTintColor:[UIColor whiteColor]];

    
    [self.wrapper setTargetView:self.previewView];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.start];
    [self.view addSubview: self.stop];
    [self.view addSubview:self.mode];
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

@end
