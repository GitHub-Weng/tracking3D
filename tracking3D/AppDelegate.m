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
        
        //navigationController.navigationBar.tintColor = [UIColor colorWithRed:26 / 255.0 green:178 / 255.0 blue:10 / 255.0 alpha:1];
        navigationController.navigationBar.tintColor = [UIColor clearColor];
        _navigationController = navigationController;
    }
    return _navigationController;
}

- (WXTabBarController *)tabBarController {
    if (_tabBarController == nil) {
        WXTabBarController *tabBarController = [WXTabBarController sharedInstance];
        
        UIViewController *mainframeViewController =
        ({
            UIViewController *mainframeViewController = [[LLAPViewController alloc] init];
            
            UIImage *mainframeImage   = [UIImage imageNamed:@"tabbar_mainframe"];
            UIImage *mainframeHLImage = [UIImage imageNamed:@"tabbar_mainframeHL"];
            
            mainframeViewController.title = @"LLAP";//这里是视图的上部的头部条
            mainframeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"llap" image:mainframeImage selectedImage:mainframeHLImage];
            //mainframeViewController.tabBarItem.badgeValue = @"9";
            mainframeViewController.tabBarItem.tag = OneDimension;
            mainframeViewController.view.backgroundColor = [UIColor colorWithRed:48 / 255.0 green:67 / 255.0 blue:78 / 255.0 alpha:1];
//            mainframeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_add"]
//                                                                                                         style:UIBarButtonItemStylePlain
//                                                                                                        target:self
//                                                                                                        action:@selector(didClickAddButton:)];
            
            mainframeViewController;
        });
        
        OpenCVViewController *visualizedController =
        ({
            OpenCVViewController *visualizedController = [[OpenCVViewController alloc] init];
        
            UIImage *contactsImage   = [UIImage imageNamed:@"tabbar_contacts"];
            UIImage *contactsHLImage = [UIImage imageNamed:@"tabbar_contactsHL"];
            
            visualizedController.title = @"tracking";
            visualizedController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"tracking" image:contactsImage selectedImage:contactsHLImage];
            visualizedController.tabBarItem.tag = Visualized;
            
            visualizedController.view.backgroundColor = [UIColor colorWithRed:115 / 255.0 green:155 / 255.0 blue:6 / 255.0 alpha:1];
            
            visualizedController;
        });
        
        UIViewController *discoverViewController = ({
            UIViewController *discoverViewController = [[UIViewController alloc] init];
            
            UIImage *discoverImage   = [UIImage imageNamed:@"tabbar_discover"];
            UIImage *discoverHLImage = [UIImage imageNamed:@"tabbar_discoverHL"];
            
            discoverViewController.title = @"发现";
            discoverViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:discoverImage selectedImage:discoverHLImage];
            discoverViewController.tabBarItem.tag = TwoDimension;
            discoverViewController.view.backgroundColor = [UIColor colorWithRed:32 / 255.0 green:85 / 255.0 blue:128 / 255.0 alpha:1];
            
            discoverViewController;
        });
        
        UIViewController *meViewController = ({
            UIViewController *meViewController = [[UIViewController alloc] init];
            
            UIImage *meImage   = [UIImage imageNamed:@"tabbar_me"];
            UIImage *meHLImage = [UIImage imageNamed:@"tabbar_meHL"];
            
            meViewController.title = @"我";
            meViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" image:meImage selectedImage:meHLImage];
            meViewController.view.backgroundColor = [UIColor colorWithRed:199 / 255.0 green:135 / 255.0 blue:56 / 255.0 alpha:1];
            
            meViewController;
        });
        
        tabBarController.title = @"微信";
        tabBarController.tabBar.tintColor = [UIColor colorWithRed:26 / 255.0 green:178 / 255.0 blue:10 / 255.0 alpha:1];
        
        tabBarController.viewControllers = @[
                                             [[UINavigationController alloc] initWithRootViewController:mainframeViewController],
                                             [[UINavigationController alloc] initWithRootViewController:visualizedController],
                                             [[UINavigationController alloc] initWithRootViewController:discoverViewController],
                                             [[UINavigationController alloc] initWithRootViewController:meViewController],
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
