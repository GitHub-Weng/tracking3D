//
//  GameViewController.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 15/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "GameViewController.h"
#import "AAPLGameViewController.h"
@interface GameViewController ()
@property AAPLGameViewController* applGameViewController;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AAPLGameViewController *gameViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
    
    // Do any additional setup after loading the view.
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

@end
