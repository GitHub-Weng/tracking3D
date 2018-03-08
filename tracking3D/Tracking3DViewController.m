//
//  Tracking3DViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 06/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "Tracking3DViewController.h"
#import "UIView+Extension.h"
@interface Tracking3DViewController ()

@property (strong,nonatomic)UIImageView* iv1;
@property (strong,nonatomic)UIImageView* iv2;
@property (strong,nonatomic)UIImageView* iv3;
@property (strong,nonatomic)UIImageView* iv4;
@property (strong,nonatomic)UIView* mouse;//模拟鼠标
@end

@implementation Tracking3DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.iv1 = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, SCREEN_WIDTH/4, SCREEN_WIDTH/4)];
    self.iv2 = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 50 - SCREEN_WIDTH/4, 100, SCREEN_WIDTH/4, SCREEN_WIDTH/4)];
    self.iv3 = [[UIImageView alloc]initWithFrame:CGRectMake(50, self.iv1.y+200, SCREEN_WIDTH/4, SCREEN_WIDTH/4)];
    self.iv4 = [[UIImageView alloc]initWithFrame:CGRectMake(self.iv2.x, self.iv1.y+200, SCREEN_WIDTH/4, SCREEN_WIDTH/4)];
    
    self.mouse = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.mouse.backgroundColor = [UIColor blackColor];
    self.mouse.layer.cornerRadius = 10;
    
    
    self.iv1.backgroundColor = [UIColor grayColor];
    self.iv2.backgroundColor = [UIColor greenColor];
    self.iv3.backgroundColor = [UIColor redColor];
    self.iv4.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:self.iv1];
    [self.view addSubview:self.iv2];
    [self.view addSubview:self.iv3];
    [self.view addSubview:self.iv4];
    
    [self.view addSubview:self.mouse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performMouseUpdate:) name:@"UpdateMouse" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)performMouseUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //self.mouse.frame =
    }
    );
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
