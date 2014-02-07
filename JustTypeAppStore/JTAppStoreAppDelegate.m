//
//  JTAppStoreAppDelegate.m
//  JustTypeAppStore
//
//  Created by Alexander Koglin on 26.01.14.
//
//

#import "JTAppStoreAppDelegate.h"
#import <JustType/JustType.h>

@implementation JTAppStoreAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[JTKeyboardListener sharedInstance] observeKeyboardGestures:YES];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"text"]) {
        
        NSString *defaultText =
        @"Welcome to a text editor providing a faster way of typing on iOS. \n\n"
        @"First try to select words in the text by touching them. "
        @"You get suggestions of the default iOS syntax checker, try to select one. \n\n"
        @"Now try to jump to words by swiping left and right on the keyboard. "
        @"You can also hold while swiping to repeat that multiple times."
        @"The more far you swipe the faster you jump in the text. \n\n"
        @"You find an arrow pointing up and down to switch the case of the selected word. "
        @"You can also swipe down for selecting the next suggestion and up for the recent one. "
        @"Enjoy!";
        
        [[NSUserDefaults standardUserDefaults] setObject:defaultText forKey:@"text"];
    }
    
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
