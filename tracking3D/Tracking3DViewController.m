//
//  Tracking3DViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "Tracking3DViewController.h"
#import "UIView+Extension.h"
#import "Wrapper.h"
#import "WaveView.h"
#import "WaveMaskView.h"
#import "TrackingButton.h"
#define DIVIDEND 13
@interface Tracking3DViewController ()

@property (strong,nonatomic)TrackingButton* iv1;
@property (strong,nonatomic)TrackingButton* iv2;
@property (strong,nonatomic)TrackingButton* iv3;
@property (strong,nonatomic)TrackingButton* iv4;
@property (strong,nonatomic)TrackingButton* iv5;
@property (strong,nonatomic)TrackingButton* iv6;
@property (strong,nonatomic)WaveMaskView *waveMaskView;
@property (strong,nonatomic)TrackingButton* muteIv;
@property (strong,nonatomic)UIView* mouse;//模拟鼠标
@property (strong,nonatomic)UILabel* llapDetectionUpDownResultLabel;//上下运动结果展示
@property (strong,nonatomic)UILabel* llapDetectionResultLabel;//模拟touch结果展示
@property (strong,nonatomic) AVAudioPlayer* audioPlayer;
@property (assign,nonatomic) int upDownCount;//统计上下的连续次数
@property (assign,nonatomic) NSInteger lastUpOrDown;//记录上次的运动是上还是下
@property (assign,nonatomic) float llap1DDistanceChangeSum;//记录上下运动的累计距离变化



@property (strong,nonatomic)Wrapper* wrapper;
@end

@implementation Tracking3DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWaveMaskView];
    [self setupAudioPlayer];
    
    self.wrapper = [Wrapper sharedInstance];
    
    float margin = SCREEN_WIDTH/DIVIDEND;
    float btnWidth = margin*2;
    
    // Do any additional setup after loading the view.
    self.iv1 = [[TrackingButton alloc]initWithFrame:CGRectMake(margin,150, btnWidth,btnWidth+15)];
    self.iv2 = [[TrackingButton alloc]initWithFrame:CGRectMake(4*margin,150, btnWidth, btnWidth+15)];
    self.iv3 = [[TrackingButton alloc]initWithFrame:CGRectMake(7*margin, 150, btnWidth, btnWidth+15)];
    self.iv4 = [[TrackingButton alloc]initWithFrame:CGRectMake(10*margin, 150, btnWidth, btnWidth+15)];
    self.iv5 = [[TrackingButton alloc]initWithFrame:CGRectMake(margin, 280, btnWidth, btnWidth+15)];
    self.iv6 = [[TrackingButton alloc]initWithFrame:CGRectMake(4*margin, 280, btnWidth, btnWidth+15)];
    
    
    self.llapDetectionUpDownResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4-60,600, SCREEN_WIDTH/4+60, 35)];
    self.llapDetectionUpDownResultLabel.backgroundColor = [CommonMethod colorWithHexString:@"#0094DF"];
    self.llapDetectionUpDownResultLabel.textColor = [UIColor whiteColor];
    self.llapDetectionUpDownResultLabel.textAlignment = NSTextAlignmentCenter;
    self.llapDetectionUpDownResultLabel.layer.borderColor = [CommonMethod colorWithHexString:@"#F5F5F5"].CGColor;
    self.llapDetectionUpDownResultLabel.layer.borderWidth = 2;
    
    self.llapDetectionResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2,600, SCREEN_WIDTH/4+60, 35)];
    self.llapDetectionResultLabel.backgroundColor = [CommonMethod colorWithHexString:@"#0094DF"];
    self.llapDetectionResultLabel.textColor = [UIColor yellowColor];
    self.llapDetectionResultLabel.textAlignment = NSTextAlignmentCenter;
    self.llapDetectionResultLabel.layer.borderColor = [CommonMethod colorWithHexString:@"#F5F5F5"].CGColor;
    self.llapDetectionResultLabel.layer.borderWidth = 2;
    
    
    self.mouse = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    UIImage* arrowImage = [UIImage imageNamed:@"arrow_icon_white.png"];
    self.mouse.layer.contents = (__bridge id)arrowImage.CGImage;
    self.mouse.backgroundColor = [UIColor clearColor];
    
    
    [self.iv1 setImage:[UIImage imageNamed:@"mobike.png"] forState:UIControlStateNormal];
    [self.iv2 setImage:[UIImage imageNamed:@"tencentVideo_icon.jpeg"] forState:UIControlStateNormal];

    [self.iv3 setImage:[UIImage imageNamed:@"wesing_icon.png"] forState:UIControlStateNormal];
    [self.iv4 setImage:[UIImage imageNamed:@"qqmusic_icon.jpg"] forState:UIControlStateNormal];
    
    [self.iv5 setImage:[UIImage imageNamed:@"wangzhe_icon.jpeg"] forState:UIControlStateNormal];
    [self.iv6 setImage:[UIImage imageNamed:@"wechat_icon.jpeg"] forState:UIControlStateNormal];
    
    [self.iv1 setAppNameLabelText:@"Mobike"];
    [self.iv2 setAppNameLabelText:@"腾讯视频"];
    [self.iv3 setAppNameLabelText:@"全名K歌"];
    [self.iv4 setAppNameLabelText:@"QQ音乐"];
    [self.iv5 setAppNameLabelText:@"王者荣耀"];
    [self.iv6 setAppNameLabelText:@"WeChat"];
    
    [self.iv1 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];
    [self.iv2 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];
    [self.iv3 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];
    [self.iv4 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];
    [self.iv5 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];
    [self.iv6 addTarget:self action:@selector(musicBtnClick) forControlEvents:UIControlEventTouchDownRepeat];

    [self.view addSubview:self.iv1];
    [self.view addSubview:self.iv2];
    [self.view addSubview:self.iv3];
    [self.view addSubview:self.iv4];
    [self.view addSubview:self.iv5];
    [self.view addSubview:self.iv6];
    [self.llapDetectionResultLabel setText:@"Touch Action"];
    [self.llapDetectionUpDownResultLabel setText:@"Up or Down"];
    [self.view addSubview:self.llapDetectionResultLabel];
    [self.view addSubview:self.llapDetectionUpDownResultLabel];
    
    [self.view addSubview:self.mouse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performMouseUpdate) name:Wrapper_UseOpenCVDetection object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performWrapper_UseLLAPDetection) name:Wrapper_UseLLAPDetection object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performWrapper_UseLLAPDetection_Up_Down) name:Wrapper_UseLLAPDetection_Up_Down object:nil];
    
    
    [self setMyBackgroundViewBGColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];


}

-(void)viewWillAppear:(BOOL)animated{
    self.llap1DDistanceChangeSum = 0;
    self.upDownCount = 0;
    self.lastUpOrDown = LLAP1DStill;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)performMouseUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint point = self.wrapper.frame2DPosition;
        self.mouse.frame = CGRectMake(point.x, point.y, self.mouse.width, self.mouse.height);
        

        //NSLog(@"isMutul---%d",isMutul); 有交互返回1   没重叠 返回0
    }
    );
}

-(void)performWrapper_UseLLAPDetection_Up_Down{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    NSString* text = @"";
    float depthPercent = 0;
    NSLog(@"llap1DDistanceChange %.2lf",self.wrapper.llap1DDistanceChange);
    switch (self.wrapper.llap1DAction) {
        case LLAP1DUp:
            if(self.lastUpOrDown == LLAP1DUp){
                self.upDownCount++;
                self.llap1DDistanceChangeSum += self.wrapper.llap1DDistanceChange;
            }
            else{
                self.upDownCount = 1;
                self.llap1DDistanceChangeSum = self.wrapper.llap1DDistanceChange;
            }
            self.lastUpOrDown = LLAP1DUp;
            text = [NSString stringWithFormat:@"Up+%d  %.2f",self.upDownCount,self.llap1DDistanceChangeSum];
            [self.llapDetectionUpDownResultLabel setText:text];
            
            [self.waveMaskView stop];
            depthPercent = self.waveMaskView.depthPercent + 0.2;
            if(depthPercent <=1){
                self.waveMaskView.depthPercent = depthPercent;
            }else{
                self.waveMaskView.depthPercent = 1;
            }
            
            [self.waveMaskView wave];
            //NSLog(@"count:%d, depthPercent:%f, self.waveMaskView.depthPercent:%f",self.upDownCount, depthPercent,self.waveMaskView.depthPercent);
            break;
        case LLAP1DDown:
            if(self.lastUpOrDown == LLAP1DDown){
                self.upDownCount++;
                self.llap1DDistanceChangeSum += self.wrapper.llap1DDistanceChange;
            }
            else{
                self.upDownCount = 1;
                self.llap1DDistanceChangeSum = self.wrapper.llap1DDistanceChange;
            }
            self.lastUpOrDown = LLAP1DDown;
            text = [NSString stringWithFormat:@"Down+%d  %.2f",self.upDownCount,self.llap1DDistanceChangeSum];
            [self.llapDetectionUpDownResultLabel setText:text];
            
            [self.waveMaskView stop];
            depthPercent = self.waveMaskView.depthPercent - 0.2;
            if(depthPercent >=0){
                self.waveMaskView.depthPercent = depthPercent;
            }else{
                self.waveMaskView.depthPercent = 0;
            }
            
            [self.waveMaskView wave];
            //NSLog(@"count:%d, depthPercent:%f, self.waveMaskView.depthPercent:%f",self.upDownCount, depthPercent,self.waveMaskView.depthPercent);
            break;
        default:
            break;

    }
        
    }
                );
    
    
    
}
-(void)performWrapper_UseLLAPDetection{
    dispatch_async(dispatch_get_main_queue(), ^{
    BOOL isMutul = NO;
    BOOL isMutulWithWaveView = NO;
    self.muteIv = nil;
    for (UIView* view in self.view.subviews) {
        if([view isKindOfClass:[TrackingButton class]]){
            isMutul = CGRectIntersectsRect(view.frame,self.mouse.frame);
            if(isMutul){
                self.muteIv = (TrackingButton*) view;
                break;
            }
        }
        if([view isKindOfClass:[WaveMaskView class]]){
            isMutulWithWaveView = CGRectIntersectsRect(view.frame,self.mouse.frame);
            if(isMutulWithWaveView){
                break;
            }
        }
    }
    if(isMutul){
            switch (self.wrapper.trackingTouchAction) {
                    
                case TTASingleClick:
                    [self.muteIv sendActionsForControlEvents:UIControlEventTouchDown];
                    [self.llapDetectionResultLabel setText:@"Single Click"];
                    break;
                case TTADoubleClick:
                    [self.muteIv sendActionsForControlEvents:UIControlEventTouchDownRepeat];
                    [self.llapDetectionResultLabel setText:@"Double Click"];
                    break;
                case TTALongPressUp:
                    [self.muteIv sendActionsForControlEvents:UIControlEventTouchDragOutside];
                    [self.llapDetectionResultLabel setText:@"Long Press Up"];
                    break;
                case TTALongPressDown:
                    [self.muteIv sendActionsForControlEvents:UIControlEventTouchUpOutside];
                    [self.llapDetectionResultLabel setText:@"Long Press Down"];
                    break;
                default:
                    break;
            }
        }
        if(isMutulWithWaveView){
            switch (self.wrapper.trackingTouchAction) {
                    
                case TTASingleClick:
                    [self changeWaveMaskViewAlpha];
                    [self.llapDetectionResultLabel setText:@"Single Click"];
                    break;
                case TTADoubleClick:
                    [self musicBtnClick];
                    [self.llapDetectionResultLabel setText:@"Double Click"];
                    break;
                case TTALongPressUp:
                    [self.llapDetectionResultLabel setText:@"Long Press Up"];
                    break;
                case TTALongPressDown:
                    [self.llapDetectionResultLabel setText:@"Long Press Down"];
                    break;
                default:
                    break;
            }
        }
        
        
    }
                   );

}

-(void) setupAudioPlayer
{
    NSError *error;
    //Add background music
    //CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFStringRef([[NSBundle mainBundle] pathForResource:@"testMusic" ofType:@"mp3"]), kCFURLPOSIXPathStyle, false);
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"testMusic.mp3" withExtension:nil];
    //CFURLRef urlRef = (__bridge CFURLRef)(url);
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if(error!=nil)
    {
        // XThrowIfError((OSStatus)error.code, "couldn't create AVAudioPlayer");
        NSLog(@"couldn't create AVAudioPlayer");
    }
    else{
        [self.audioPlayer setNumberOfLoops: -1];
    }
    [self.audioPlayer setVolume:0.01];
    //CFRelease(url);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma -mark WaveView
- (void)setupWaveView:(BOOL)isCircle {
    
    WaveView *waveView = [[WaveView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:waveView];
    waveView.center = CGPointMake(self.view.center.x, self.view.center.y - (isCircle ? 0 : 150));
    waveView.backgroundColor = [UIColor whiteColor];
    waveView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    waveView.layer.borderWidth = 1.f;
    if (isCircle) {
        waveView.layer.cornerRadius = 50;
        waveView.clipsToBounds = YES;
    }
    
    waveView.speed = 2;
    waveView.depthPercent = 0;
    waveView.waveColor = [UIColor colorWithRed:105/255.0 green:186/255.0 blue:241/255.0 alpha:1];
    
    [waveView wave];
}

- (void)setupWaveMaskView {
    
    self.waveMaskView = [[WaveMaskView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, SCREEN_WIDTH/3) bottomImage:[UIImage imageNamed:@"bottom"] upImage:[UIImage imageNamed:@"up"]];
    self.waveMaskView.layer.borderWidth = 3;
    UIColor* color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    self.waveMaskView.layer.borderColor = color.CGColor;
    self.waveMaskView.layer.cornerRadius = SCREEN_WIDTH/6;
    self.waveMaskView.layer.masksToBounds = YES;
   
    [self.view addSubview:self.waveMaskView];
    self.waveMaskView.center = CGPointMake(self.view.center.x, self.view.center.y+100);
    self.waveMaskView.backgroundColor = [UIColor clearColor];
    
    self.waveMaskView.speed = 8;
    self.waveMaskView.depthPercent = 0;
    
    [self.waveMaskView wave];
}
-(void) playMySound:(AVAudioPlayer *)audioPlayer
{
    [self.audioPlayer play];
}

-(void) stopMySound
{
    [self.audioPlayer stop];
}
-(void)musicBtnClick
{
    if([self.audioPlayer isPlaying])
    {
        [self.audioPlayer stop];
    }else{
        [self.audioPlayer play];
    }
}

-(void)changeWaveMaskViewAlpha{
    if(self.waveMaskView.alpha == 1){
        self.waveMaskView.alpha = 0.5;
    }else{
        self.waveMaskView.alpha = 1;
    }
}

@end
