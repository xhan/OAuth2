//
//  OAAppDelegate.m
//  OAuth2
//
//  Created by xu xhan on 2/24/12.
//  Copyright (c) 2012 Less Everything. All rights reserved.
//

#import "OAAppDelegate.h"
//#import <>
//#import "NXOAuth2.h"
#import "NXOAuth2.h"
#import "OAViewController.h"

@implementation OAAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


+ (void)initialize;
{
    [[NXOAuth2AccountStore sharedStore] setClientID:@"609011242"
                                             secret:@"f5b209105c1735f86cc7324fed6873b5"
                                   authorizationURL:[NSURL URLWithString:@"https://api.weibo.com/oauth2/authorize?display=mobile"]
                                           tokenURL:[NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"]
                                        redirectURL:[NSURL URLWithString:@"app://test.com"]
                                     forAccountType:@"myFancyService"];
    
    
    [[NXOAuth2AccountStore sharedStore] setClientID:@"f74f74797e644ee49e35f407092f6ec5"
                                             secret:@"15e6644eec424855acd99ce9a551c0da"
                                   authorizationURL:[NSURL URLWithString:@"https://graph.renren.com/oauth/authorize?response_type=token&display=touch"]
                                           tokenURL:[NSURL URLWithString:@"https://graph.renren.com/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"http://graph.renren.com/oauth/login_success.html"]
                                     forAccountType:@"renren"];
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[OAViewController alloc] initWithNibName:@"OAViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
