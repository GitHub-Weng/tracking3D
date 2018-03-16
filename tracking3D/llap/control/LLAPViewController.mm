//
//  LLAPViewController.m
//  aurioTouch
//
//  Created by wengdada on 25/02/2018.
//

#import "LLAPViewController.h"

@interface LLAPViewController ()
@property UIButton* startBtn;
@property UIButton* stopBtn;
@property UISlider* distanceChangeSlider;
@property UILabel*  distanceChangeLabel;
@property float     distanceChangeSum;//实时变化的距离累计，当累计值到达一定值的时候才会更新label
@property (nonatomic,strong)AudioController* audioController;
@end

@implementation LLAPViewController

-(id)init
{
    if (self = [super init]) {
        self.startBtn = [[UIButton alloc]init];
        self.stopBtn = [[UIButton alloc]init];
        self.distanceChangeSlider = [[UISlider alloc]init];
        self.distanceChangeLabel = [[UILabel alloc]init];
        
        self.startBtn.backgroundColor = [UIColor clearColor];
        self.stopBtn.backgroundColor = [UIColor clearColor];
        self.distanceChangeLabel.backgroundColor = [UIColor whiteColor];
       
        self.audioController = [AudioController sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performDisUpdate:) name:@"AudioController_AudioDisUpdate" object:nil];
        
        
        self.startBtn.frame = CGRectMake(80, SCREEN_HEIGHT/4, 90, 90);
        [self.startBtn setImage:[UIImage imageNamed:@"startbtn_icon_white"] forState:UIControlStateNormal];
        [self.startBtn setImage:[UIImage imageNamed:@"startbtn_icon_yellow"] forState:UIControlEventTouchDown];
        
        self.stopBtn.frame = CGRectMake(SCREEN_WIDTH-160, SCREEN_HEIGHT/4, 90, 90);
        [self.stopBtn setImage:[UIImage imageNamed:@"stopbtn_icon_white"] forState:UIControlStateNormal];
        [self.stopBtn setImage:[UIImage imageNamed:@"stopbtn_icon_yellow"] forState:UIControlEventTouchDown];

        [self.startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchDown];
        [self.stopBtn addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchDown];\
        self.distanceChangeSlider.frame = CGRectMake(SCREEN_WIDTH/10, self.startBtn.bottom+200, SCREEN_WIDTH*0.8, 5);
        [self.distanceChangeSlider setThumbImage:[UIImage imageNamed:@"dotspin"] forState:UIControlStateNormal];
        self.distanceChangeLabel.frame = CGRectMake(SCREEN_WIDTH/10, self.distanceChangeSlider.bottom+20, SCREEN_WIDTH*0.8, 30);
        self.distanceChangeLabel.textAlignment = NSTextAlignmentCenter;
        self.distanceChangeLabel.text = @"LLAP测得的距离变化";
        self.distanceChangeLabel.alpha = 0.7;
       
        
        [self.view addSubview:self.startBtn];
        [self.view addSubview:self.stopBtn];
        [self.view addSubview:self.distanceChangeLabel];
        [self.distanceChangeSlider setValue: 0.0];
        [self.view addSubview: self.distanceChangeSlider];
        //[self setMyBackgroundViewBGColor:[UIColor blackColor]];
        [self setMyBackgroundViewImage:@"mybackground4.jpeg"];
        
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view, typically from a nib.

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)performDisUpdate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int tempdis=(int) self.audioController.audiodistance/DISPLAY_SCALE;
        
        self.distanceChangeSlider.value=(self.audioController.audiodistance-DISPLAY_SCALE*tempdis)/DISPLAY_SCALE;
        float distanceChange = [self.audioController getDistanceChange];
        self.distanceChangeSum += distanceChange;
        if(fabsf(self.distanceChangeSum)>5){
             [self.distanceChangeLabel setText:[NSString stringWithFormat:@"LLAP测得距离变化:%.2f",self.distanceChangeSum]];
        }
       
    }
                   );
    
}
-(void)performDisUpdateDistanceChangeLabel{
    dispatch_async(dispatch_get_main_queue(), ^{

    }
                   );
}
- (void)startBtnClicked:(UIButton *)sender {
    self.audioController.audiodistance = 0;
    [self.audioController startIOUnit];
}
- (void)stopBtnClicked:(UIButton *)sender {
    [self.audioController stopIOUnit];
}

-(AudioController*)getAudioController{
    return self.audioController;
}
@end
