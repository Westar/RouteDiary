//
//  RouteDetailViewController.h
//  RouteTracker
//

/**
 * View Controller to display the given route's informations
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Route;

@interface RouteDetailViewController : UIViewController <MKMapViewDelegate>

/// route object to display
@property (nonatomic, strong) Route *routeToDisplay;
/// label to display start time
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
/// label to display finish time
@property (weak, nonatomic) IBOutlet UILabel *finishTimeLabel;
/// label to display duration
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
/// label to display distance
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
/// label to display average speed
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
/// label to display maximum speed
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
/// label to display a little joke label, if the user's maximum speed exceeded 180km/h
@property (weak, nonatomic) IBOutlet UILabel *jokeLabel;
/// magnifier button to make the mapview fullscreen
@property (weak, nonatomic) IBOutlet UIButton *magnifierButton;

@property (weak, nonatomic) UIButton *closeButton;
/// mapView to display the route
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIButton *fb;
@property (strong, nonatomic) IBOutlet UIButton *tw;
@property (strong, nonatomic) IBOutlet UIButton *em;
@property (strong, nonatomic) IBOutlet UIButton *gpx;




- (id)initWith:(Route*)route;
- (IBAction)showMapFullScreen;
- (IBAction)goBack;
- (IBAction)exportRouteinGPXFormatViaEmail;
- (IBAction)postToTwitter:(id)sender;
- (IBAction)postToFacebook:(id)sender;
- (IBAction)showEmail:(id)sender;



@end
