//
//  AppDelegate.m
//  llap
//
//  Created by Ke Sun on 5/18/17.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenCVViewController.h"
#import "WXTabBarController.h"
#import "LLAPViewController.h"
#import "Tracking3DViewController.h"
#import "CommonMethod.h"
@interface AppDelegate ()

@property (nonatomic, strong) WXTabBarController *tabBarController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





- (UINavigationController *)navigationController {
    if (_navigationController == nil) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];


        _navigationController = navigationController;
    }
    return _navigationController;
}

- (WXTabBarController *)tabBarController {
    if (_tabBarController == nil) {
        WXTabBarController *tabBarController = [WXTabBarController sharedInstance];
        
        LLAPViewController *llapViewController =
        ({
            LLAPViewController *llapViewController = [[LLAPViewController alloc] init];
            
            UIImage *mainframeImage   = [UIImage imageNamed:@"sound_icon"];
            UIImage *mainframeHLImage = [UIImage imageNamed:@"sound_selected_icon"];
            
            llapViewController.title = @"LLAP";//这里是视图的上部的头部条
            llapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"llap" image:mainframeImage selectedImage:mainframeHLImage];
            //llapViewController.tabBarItem.badgeValue = @"9";
            llapViewController.tabBarItem.tag = OneDimension;
            llapViewController.view.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
           
//            llapViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_add"]
//                                                                                                         style:UIBarButtonItemStylePlain
//                                                                                                        target:self
//                                                                                                        action:@selector(didClickAddButton:)];
            
            llapViewController;
        });
        
        OpenCVViewController *openCVViewController =
        ({
            OpenCVViewController *openCVViewController = [[OpenCVViewController alloc] init];
        
            UIImage *contactsImage   = [UIImage imageNamed:@"video_icon"];
            UIImage *contactsHLImage = [UIImage imageNamed:@"video_selected_icon"];
            
            openCVViewController.title = @"openCV";
            openCVViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"openCV" image:contactsImage selectedImage:contactsHLImage];
            openCVViewController.tabBarItem.tag = Visualized;
            
            openCVViewController.view.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
            openCVViewController;
        });
        
        Tracking3DViewController *tracking3DViewController = ({
            Tracking3DViewController *tracking3DViewController = [[Tracking3DViewController alloc] init];
            
            UIImage *discoverImage   = [UIImage imageNamed:@"track_icon"];
            UIImage *discoverHLImage = [UIImage imageNamed:@"track_selected_icon"];
            
            tracking3DViewController.title = @"tracking";
            tracking3DViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"tracking" image:discoverImage selectedImage:discoverHLImage];
            tracking3DViewController.tabBarItem.tag = TwoDimension;
            tracking3DViewController.view.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
            
            tracking3DViewController;
        });
        
        UIViewController *tracking3DGameViewController = ({
            UIViewController *tracking3DGameViewController = [[UIViewController alloc] init];
            
            UIImage *meImage   = [UIImage imageNamed:@"game_icon"];
            UIImage *meHLImage = [UIImage imageNamed:@"game_selected_icon"];
            
            tracking3DGameViewController.title = @"game";
            tracking3DGameViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"game" image:meImage selectedImage:meHLImage];
            tracking3DGameViewController.view.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1];
            
            tracking3DGameViewController;
        });
        
        tabBarController.title = @"3DTracking";
        
        tabBarController.tabBar.tintColor = [CommonMethod colorWithHexString:@"#0094DF"];

        tabBarController.viewControllers = @[
                                             [[UINavigationController alloc] initWithRootViewController:llapViewController],
                                             [[UINavigationController alloc] initWithRootViewController:openCVViewController],
                                             [[UINavigationController alloc] initWithRootViewController:tracking3DViewController],
                                             [[UINavigationController alloc] initWithRootViewController:tracking3DGameViewController],
                                             ];
        
        _tabBarController = tabBarController;
    
    }
    return _tabBarController;
}

- (void)didClickAddButton:(id)sender {
    OpenCVViewController *viewController = [[OpenCVViewController alloc] init];
    
    viewController.title = @"添加";
    viewController.view.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:178 / 255.0 blue:10 / 255.0 alpha:1];
    
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
