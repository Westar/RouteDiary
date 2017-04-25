//
//  RouteDetailViewController.m
//  RouteTracker
//

#import "RouteDetailViewController.h"
#import "Route.h"
#import "LocationPoint.h"
#import <QuartzCore/QuartzCore.h>
#import "CoordinateObject.h"
#import <GPX/GPX.h>
#import "DataExporter.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h> 



@interface RouteDetailViewController () <MFMailComposeViewControllerDelegate>
{
    UILabel *noteLabel;
}
/// handler to share routes on fb, tw or email

/// YES if it should show the actionsheet to share the route on fb, tw or email

/// the original center of the view

/// data exporter class' property
@property (nonatomic, strong) DataExporter *dataExp;
@end

@implementation RouteDetailViewController
@synthesize fb,tw,em,gpx;
/**
 * Init for the view controller. Initialize it with a Route object.
 * @param route object to display
 * @return id self
 */
- (id)initWith:(Route*)route
{
    self = [super init];
    if (self)
    {
        self.routeToDisplay = route;
    }
    return self;
}

//TWITTER
- (IBAction)postToTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Started: %@, distance: %@, duration: %@, finished: %@, Max speed: %@, Avg speed: %@", self.startTimeLabel.text, self.distanceLabel.text, self.durationLabel.text, self.finishTimeLabel.text, self.maxSpeedLabel.text, self.averageSpeedLabel.text]];
        
        [tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/routediary/id647586810?mt=8"]];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

//FACEBOOK
- (IBAction)postToFacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        //[controller setInitialText:@""];
        
        [controller setInitialText:[NSString stringWithFormat:@"I started this route at: %@, during that I took: %@ in %@ and ended it at %@. My max speed was: %@ while the average: %@", self.startTimeLabel.text, self.distanceLabel.text, self.durationLabel.text, self.finishTimeLabel.text, self.maxSpeedLabel.text, self.averageSpeedLabel.text]];
        
        [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/routediary/id647586810?mt=8"]];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
}

//EMAIL
- (IBAction)showEmail:(id)sender
{
    // Email Subject
    NSString *emailTitle = @"My Route";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"I started this route at: %@, during that I took: %@ in %@ and ended it at %@. My max speed was: %@ while the average: %@", self.startTimeLabel.text, self.distanceLabel.text, self.durationLabel.text, self.finishTimeLabel.text, self.maxSpeedLabel.text, self.averageSpeedLabel.text];
    [NSURL URLWithString:@"https://itunes.apple.com/ru/app/routediary/id647586810?mt=8"];
        // To address
    //NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    //[mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



    



- (IBAction)showMapFullScreen
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mapView.frame = self.view.bounds;
                         [self.view bringSubviewToFront:self.mapView];
                         [self.mapView.layer setBorderColor:nil];
                         [self.mapView.layer setBorderWidth:0.0];
                     } completion:^(BOOL finished) {
                         // zoom to the route
                         [self.mapView addSubview:self.closeButton];
                     }];
}

/**
 * Minize the mapView to normal size and remove the close button.
 */
- (void)minimizeMapView
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.closeButton removeFromSuperview];
                         CGRect frame = CGRectMake(10.0, 50.0, 300.0, 150.0);
                         self.mapView.frame = frame;
                         [self.mapView.layer setBorderColor:[UIColor whiteColor].CGColor];
                         [self.mapView.layer setBorderWidth:8.0];
                     } completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:self.magnifierButton];
                     }];
}

/**
 * A close button to be able to close the mapview if it's in full screen mode.
 * @return UIButton close button
 */
- (UIButton*)closeButton
{
    if (!_closeButton)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setFrame:CGRectMake(self.view.frame.size.width - 31.0, self.view.frame.size.height - 31.0, 26.0, 26.0)];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonPressed.png"] forState:UIControlStateSelected];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonPressed.png"] forState:UIControlStateHighlighted];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton addTarget:self action:@selector(minimizeMapView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

/**
 * Dismiss the view
 * @return IBAction action
 */
- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - mapview delegate methods
/**
 * Stop tracking the user and save the route.
 * @param mapView The map view that requested the overlay view.
 * @param overlay The object representing the overlay that is about to be displayed.
 * @return MKOverlayView The view to use when presenting the specified overlay on the map. If you return nil, no view is displayed for the specified overlay object.
 */
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.strokeColor = [UIColor darkGrayColor];
    overlayView.lineWidth = 10.0f;

    return overlayView;
}

#pragma mark - exporting
/**
 * Export the GPX file via mail. Call the dataexporter class with the selected route to create the file for exporting.
 * @return IBAction action
 */
- (IBAction)exportRouteinGPXFormatViaEmail;
{
    self.dataExp = [[DataExporter alloc] initWithRoutes:@[self.routeToDisplay] andParent:self];
    [self.dataExp exportViaEmail];
}


#pragma mark - view methods
/**
 * Customize the mapview, labels, and read out informations from route object and load it's content to the outlets.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
   // [self customizeLabels];

    [self.mapView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.mapView.layer setBorderWidth:8.0];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [self.startTimeLabel setText:[dateFormatter stringFromDate:self.routeToDisplay.startTime]];
    [self.finishTimeLabel setText:[dateFormatter stringFromDate:self.routeToDisplay.endTime]];
    int duration = [self.routeToDisplay.duration intValue];
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = (duration / 3600);
    [self.durationLabel setText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds]];
    [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f km", [self.routeToDisplay.distance floatValue] / 1000.0]];
    [self.averageSpeedLabel setText:[NSString stringWithFormat:@"%.0f km/h", [self.routeToDisplay.avgSpeed floatValue]]];
    [self.maxSpeedLabel setText:[NSString stringWithFormat:@"%.0f km/h", [self.routeToDisplay.maxSpeed floatValue]]];


    //[self.view setBackgroundColor:RGB(250.0, 250.0, 250.0)];
    [self drawRouteOnMap];

    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
}

/**
 * Draw the route of the tracking to the mapview. Create the crumbs object with the first coordinate, then sort the array to have the coordinates in order.
 * Than iterate through the array and add each coordinate to the crumbs object, than add it to the map.
 */
- (void)drawRouteOnMap
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        LocationPoint *locP = [self.routeToDisplay.locationPoints.allObjects objectAtIndex:0];
        CLLocationCoordinate2D firstLocationCoordinate = CLLocationCoordinate2DMake([locP.latitude doubleValue], [locP.longitude doubleValue]);

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [[self.routeToDisplay.locationPoints allObjects] sortedArrayUsingDescriptors:sortDescriptors];

        CLLocationCoordinate2D coors[sortedArray.count];

        int index = 0;
        for (LocationPoint *locPoint in sortedArray)
        {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locPoint.latitude doubleValue], [locPoint.longitude doubleValue]);
            coors[index] = coordinate;
            index++;
        }
        MKPolyline *line = [MKPolyline polylineWithCoordinates:coors count:sortedArray.count];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.mapView addOverlay:line];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(firstLocationCoordinate, 500, 500);
            [self.mapView setRegion:region animated:YES];
        });
    });
}

/**
 * Animate the view back to it's original state
 */
- (void)animateViewBack
{
    CGRect originalFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = originalFrame;
                     }
                     completion:nil];
}
    


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view addSubview:noteLabel];
}


/**
 * Sent to the view controller when the app receives a memory warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * Dealloc method to deallocate any references or allocations
 */
- (void)dealloc
{
    [self setStartTimeLabel:nil];
    [self setFinishTimeLabel:nil];
    [self setDurationLabel:nil];
    [self setDistanceLabel:nil];
    [self setAverageSpeedLabel:nil];
    [self setMaxSpeedLabel:nil];
    [self setJokeLabel:nil];
    [self setMagnifierButton:nil];
    [self setMapView:nil];
    [self setCloseButton:nil];
}

- (void)viewDidUnload {
   // [self setShowEmail:nil];
    [self setFb:nil];
    [self setTw:nil];
    [self setEm:nil];
    [self setGpx:nil];
    [super viewDidUnload];
}
@end
