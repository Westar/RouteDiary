//
//  MainViewController.h
//  RouteTracker
//

/**
 * Main View controller of the app.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationHandler.h"

@interface MainViewController : UIViewController <MKMapViewDelegate, LocationHandlerDelegate>

/// location handler object to read the gps
@property (nonatomic, strong) LocationHandler *locHandler;
/// map to display the user
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
/// list button to open the list of routes
@property (weak, nonatomic) IBOutlet UIButton *listButton;
/// button to locate the user
@property (weak, nonatomic) IBOutlet UIButton *locateButton;
/// dashboardview where all the labels are (for later animations)
@property (weak, nonatomic) IBOutlet UIView *dashboardView;
/// start button
@property (weak, nonatomic) IBOutlet UIButton *startButton;
/// stop button
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

/// label to display current speed
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
/// label to display average speed
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
/// label to display maximum speed
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
/// label to display the duration
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
/// label to display the distance
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (strong, nonatomic) IBOutlet UIImageView *currentSpeedImage;

@property (strong, nonatomic) IBOutlet UILabel *routeDiary;


- (IBAction)startPressed;
- (IBAction)stopPressed;
- (IBAction)listButtonPressed;
- (IBAction)locateButtonPressed;

@end
