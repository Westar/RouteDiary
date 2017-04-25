//
//  AppDelegate.m
//  RouteTracker
//

#import "AppDelegate.h"

@implementation AppDelegate

/**
 Initializes mainViewController and set it as the rootViewController of the application.
 @param application The delegating application object.
 @param launchOptions A dictionary indicating the reason the application was launched (if any). The contents of this dictionary may be empty in situations where the user launched the application directly. For information about the possible keys in this dictionary and how to handle them, see “Launch Options Keys”.
 @return NO if the application cannot handle the URL resource, otherwise return YES. The return value is ignored if the application is launched as a result of a remote notification.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainVC = [[MainViewController alloc] init];
    [self.window setRootViewController:self.mainVC];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
