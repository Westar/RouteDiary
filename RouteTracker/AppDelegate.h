//
//  AppDelegate.h
//  RouteTracker
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/// application's main window
@property (strong, nonatomic) UIWindow *window;
/// application's mainViewController that holds everything in place
@property (strong, nonatomic) MainViewController *mainVC;

@end
