//
//  DataExporter.h
//  RouteTracker
//

#import <Foundation/Foundation.h>
#import "GPX.h"
#import "Route.h"
#import <MessageUI/MessageUI.h>

/**
 A Class to handle all the dataexporting issues and emailing.
 This class creates the gpx files and sends them via email.
 */

@interface DataExporter : NSObject <MFMailComposeViewControllerDelegate>

/// array that contains the passed in routes
@property (nonatomic, strong) NSMutableArray *routesArray;
/// view controller which calls the exporting of the routes
@property (nonatomic, strong) UIViewController *parentViewController;

- (id)initWithRoutes:(NSArray*)routes andParent:(UIViewController*)parentVC;
- (void)exportViaEmail;

@end
