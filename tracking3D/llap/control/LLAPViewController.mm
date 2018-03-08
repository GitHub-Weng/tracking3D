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
@property UILabel* phaseChangeLabel;
@property UILabel* distanceChangeLabel;
@property (nonatomic,strong)AudioController* audioController;
@end

@implementation LLAPViewController

-(id)init
{
    if (self = [super init]) {
        self.startBtn = [[UIButton alloc]init];
        self.stopBtn = [[UIButton alloc]init];
        self.distanceChangeSlider = [[UISlider alloc]init];
        self.phaseChangeLabel = [[UILabel alloc]init];
        self.distanceChangeLabel = [[UILabel alloc]init];
        
        self.startBtn.backgroundColor = [UIColor whiteColor];
        self.stopBtn.backgroundColor = [UIColor whiteColor];
        self.distanceChangeLabel.backgroundColor = [UIColor whiteColor];
        self.phaseChangeLabel.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view, typically from a nib.
    self.audioController = [[AudioController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performDisUpdate:) name:@"AudioDisUpdate" object:nil];
    
    
    self.startBtn.frame = CGRectMake(50, 100, 100, 50);
    [self.startBtn setTitle:@"StartLLAP" forState:UIControlStateNormal];
    self.stopBtn.frame = CGRectMake(200, 100, 100, 50);
    [self.startBtn setTitle:@"StopLLAP" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchDown];
    [self.stopBtn addTarget:self action:@selector(stopBtnClicked:) forControlEvents:UIControlEventTouchDown];
    self.distanceChangeLabel.frame = CGRectMake(50, 200, 100, 50);
    self.phaseChangeLabel.frame = CGRectMake(200, 200, 100, 50);
    self.distanceChangeSlider.frame = CGRectMake(25, 300, SCREEN_WIDTH - 50, 10);
    
    self.distanceChangeLabel.text = @"DC:";
    self.phaseChangeLabel.text = @"PC:";
    
    
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.stopBtn];
    [self.view addSubview:self.distanceChangeLabel];
    [self.view addSubview:self.phaseChangeLabel];
    [self.distanceChangeSlider setValue: 0.0];
    [self.view addSubview: self.distanceChangeSlider];
    
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
