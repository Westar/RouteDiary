//
//  MainViewController.m
//  RouteTracker
//

#import "MainViewController.h"
#import "RoutesViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CoreDataHandler.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import "CoordinateObject.h"

@interface MainViewController ()
/// timer to measure the elapsed time
@property (nonatomic, strong) NSTimer *durationTimer;
/// object to hold all location points
@property (nonatomic, strong) CrumbPath *crumbs;
/// the route view to draw on the map
@property (nonatomic, strong) CrumbPathView *crumbView;
/// the start date of the tracking
@property (nonatomic) NSDate *startDate;
/// the end date of the tracking
@property (nonatomic) NSDate *endDate;
/// if YES, app tracks user locations, movements
@property (nonatomic) BOOL isTracking;
/// if YES, the tracking has been paused
@property (nonatomic) BOOL isTrackingPaused;
/// property to store total distance of the tracking
@property (nonatomic) float totalDistance;
/// property to store total duration of the tracking
@property (nonatomic) int totalDuration;
/// property to store maximum speed
@property (nonatomic) float maxSpeed;
/// property to store average speed
@property (nonatomic) float avgSpeed;
/// a helper array to hold all the location points
@property (nonatomic, strong) NSMutableArray *locationPoints;
@end

@implementation MainViewController

@synthesize currentSpeedImage=_currentSpeedImage;

/**
 * Start tracking the user's movement, or if tracking is enabled pause tracking.
 * @return IBAction action
 */
- (IBAction)startPressed
{
    if (self.isTracking)
    {
        [self.locHandler idleLocationUpdate];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.isTracking = NO;
        self.isTrackingPaused = YES;
        self.crumbs.isTrackingPaused = NO;
        [self stopDurationTimer];
        
        [_currentSpeedImage stopAnimating];
    }
    else
    {
        if (self.isTrackingPaused)
        {
            ///continue previous start
            self.isTracking = YES;
            self.isTrackingPaused = NO;
            self.crumbs.isTrackingPaused = NO;
            
            [_currentSpeedImage startAnimating];
        }
        else
        {
            /// initial start
            self.startDate = [NSDate date];
            self.isTracking = YES;
            self.isTrackingPaused = NO;
            self.crumbs.isTrackingPaused = NO;
            
        }
        [self.locHandler startLocationUpdate];
        [self startDurationTimer];
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    
    
}

/**
 * Stop tracking the user and save the route.
 * @return IBAction action
 */
- (IBAction)stopPressed
{
    [self.locHandler idleLocationUpdate];
    [self stopDurationTimer];
    if (self.totalDistance > 0)
    {
        [self saveRoute];
    }
    else
    {
        [self resetLabels];
        [self resetValues];
    }
    self.isTracking = NO;
    self.isTrackingPaused = NO;
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
}

/**
 * Open the routes list view controller.
 * @return IBAction action
 */
- (IBAction)listButtonPressed
{
    RoutesViewController *routesVC = [[RoutesViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:routesVC];
    [navCtrl setNavigationBarHidden:YES animated:YES];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

/**
 * Locate the user and zoom to their current location.
 * @return IBAction action
 */
- (IBAction)locateButtonPressed
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.locHandler.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:region animated:YES];
    [self.mapView.userLocation setCoordinate:self.locHandler.userLocation.coordinate];
    [self.mapView addAnnotation:self.mapView.userLocation];
}

/**
 * Save the route to Core Data and after it completes reset values and labels.
 */
- (void)saveRoute
{
    self.endDate = [NSDate date];
    [[CoreDataHandler sharedInstance] saveRouteWithStartTime:self.startDate
                                                     endTime:self.endDate
                                                    duration:self.totalDuration
                                                      points:self.locationPoints
                                                    avgSpeed:self.avgSpeed
                                                    maxSpeed:self.maxSpeed
                                                    distance:self.totalDistance
                                         withCompletionBlock:^{
                                             [self resetValues];
                                             [self resetLabels];
    }];
}

/**
 * Reset all values.
 */
- (void)resetValues
{
    self.maxSpeed = 0.0;
    self.endDate = nil;
    self.startDate = nil;
    self.totalDistance = 0.0;
    self.totalDuration = 0;
    self.avgSpeed = 0.0;
    [self.mapView removeOverlay:self.crumbView.overlay];
    self.crumbs = nil;
    self.crumbView = nil;
    [self.locationPoints removeAllObjects];
}

/**
 * Reset all labels.
 */
- (void)resetLabels
{
    [self.currentSpeedLabel setText:@"0"];
    [self.avgSpeedLabel setText:@"0 km/h"];
    [self.maxSpeedLabel setText:@"0 km/h"];
    [self.durationLabel setText:@"00:00:00"];
    [self.distanceLabel setText:@"0 m"];
}

#pragma mark - location handler delegate method
/**
 * LocationHandler's delegate method, which is called every time a new location is available, if so, update the labels. If not tracking, only update the current speed.
 * @param location the new location info
 * @param distanceDelta the new distance value
 */
- (void)updateLabelsWithLocationData:(CLLocation *)location andDistanceDelta:(CLLocationDistance)distanceDelta
{
    if (location.speed > 0.0)
    {
        [self.currentSpeedLabel setText:[NSString stringWithFormat:@"%.0f", location.speed * 3.6]];
    }
    else
    {
        [self.currentSpeedLabel setText:@"0"];
    }
    if (self.isTracking)
    {
        [self checkMaximumSpeed:location.speed * 3.6];
        [self.maxSpeedLabel setText:[NSString stringWithFormat:@"%.0f km/h", self.maxSpeed]];

        self.totalDistance += distanceDelta;
        if (self.totalDistance > 1000.0)
        {
            [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f km", self.totalDistance / 1000.0]];
        }
        else
        {
            [self.distanceLabel setText:[NSString stringWithFormat:@"%.0f m", self.totalDistance]];
        }

        [self.avgSpeedLabel setText:[NSString stringWithFormat:@"%.0f km/h", [self updateAvgSpeed]]];

        /// add a new coordinate object with timestamp
        CoordinateObject *coordinateO = [[CoordinateObject alloc] init];
        coordinateO.coord = location.coordinate;
        coordinateO.elevation = location.altitude;
        coordinateO.timeStamp = [[NSDate date] timeIntervalSince1970];
        [self.locationPoints addObject:coordinateO];

        [self updateTrackViewForLocation:location];
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        [self.mapView.userLocation setCoordinate:location.coordinate];
        [self.mapView addAnnotation:self.mapView.userLocation];
    }
    else
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:YES];
        [self.mapView.userLocation setCoordinate:location.coordinate];
        [self.mapView addAnnotation:self.mapView.userLocation];
    }
}

/**
 * Start a timer to measure the duration of the tracking
 */
- (void)startDurationTimer
{
    if (![self.durationTimer isValid])
    {
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
    }
}

/**
 * Update the total duration by 1 and update the label.
 */
- (void)updateDuration
{
    self.totalDuration++;
    [self.durationLabel setText:[self formatDurationIntoString]];
}

/**
 * Create a string to make time easily readable
 * @return NSString string to return
 */
- (NSString*)formatDurationIntoString
{
    int seconds = self.totalDuration % 60;
    int minutes = (self.totalDuration / 60) % 60;
    int hours = (self.totalDuration / 3600);
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
}

/**
 * Stop duration timer if it's still running.
 */
- (void)stopDurationTimer
{
    if ([self.durationTimer isValid])
    {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

/**
 * Update the average speed after 10 seconds (from initial start).
 * @return float average speed
 */
- (float)updateAvgSpeed
{
	if (self.totalDuration > 10) // wait couple of seconds till updating the avg speed, since it would show an invalid data
    {
        float averageSpeed = (self.totalDistance / self.totalDuration) * 3.6;
        self.avgSpeed = averageSpeed;
        if (self.avgSpeed < self.maxSpeed)
        {
            return averageSpeed;
        }
	}
    return 0;
}

/**
 * Update the trackview for the given location. Draw content on the map
 * @param newLocation new location to be used.
 */
- (void)updateTrackViewForLocation:(CLLocation*)newLocation
{
    if (!self.crumbs)
    {
        // This is the first time we're getting a location update, so create
        // the CrumbPath and add it to the map.
        //
        _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
        [self.mapView addOverlay:self.crumbs];

        // On the first location update only, zoom map to user location
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:YES];
    }
    else
    {
        // This is a subsequent location update.
        // If the crumbs MKOverlay model object determines that the current location has moved
        // far enough from the previous location, use the returned updateRect to redraw just
        // the changed area.
        //
        // note: iPhone 3G will locate you using the triangulation of the cell towers.
        // so you may experience spikes in location data (in small time intervals)
        // due to 3G tower triangulation.
        //
        MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];

        if (!MKMapRectIsNull(updateRect))
        {
            // There is a non null update rect.
            // Compute the currently visible map zoom scale
            MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
            // Find out the line width at this zoom scale and outset the updateRect by that amount
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            // Ask the overlay view to update just the changed area.
            [self.crumbView setNeedsDisplayInMapRect:updateRect];
        }
    }
}

/**
 * Check for maximum speed. Compare the current speed with the stored max speed, and if current speed is bigger than max, make it the maximum speed.
 * @param currentSpeed current speed of user
 */
- (void)checkMaximumSpeed:(float)currentSpeed
{
    if (currentSpeed > self.maxSpeed)
    {
        self.maxSpeed = currentSpeed;
    }
}

#pragma mark - mapview delegate methods
/**
 * Called when location is changed. If currentLocation is equal to the passed in param and isLocationShowAllowed equals YES, than update location by calling showLocation method.
 * @param mapView map that displays location informations
 * @param userLocation location of the user
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (CLLocationCoordinate2DIsValid(userLocation.coordinate))
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:YES];
    }
}

/**
 * Returns the view associated with the specified annotation object.
 * @param mapView The map view that requested the annotation view.
 * @param annotation The object representing the annotation that is about to be displayed. In addition to your custom annotations, this object could be an MKUserLocation object representing the user’s current location.
 * @return MKAnnotationView The annotation view to display for the specified annotation or nil if you want to display a standard annotation view.
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
    {
        MKAnnotationView *userLocationView = (MKAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"userLocation"];
        if (userLocationView == nil)
        {
            userLocationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocation"];
        }
        else
        {
            userLocationView.annotation = annotation;
        }
        userLocationView.image = [UIImage imageNamed:@"pointer.png"];
        userLocationView.canShowCallout = NO;
        return userLocationView;
    }
    else
    {
        return nil;
    }
}

/**
 * Stop tracking the user and save the route.
 * @param mapView The map view that requested the overlay view.
 * @param overlay The object representing the overlay that is about to be displayed.
 * @return MKOverlayView The view to use when presenting the specified overlay on the map. If you return nil, no view is displayed for the specified overlay object.
 */
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}

#pragma mark - view methods
/**
 * Called after view loaded. Sets background color, start location updating and reset values if tracking is not active.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.dashboardView setBackgroundColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0]];
    if (!self.isTracking)
    {
        [self resetValues];
        [self resetLabels];
    }
    [self.locHandler startLocationUpdate];
    self.locationPoints = [[NSMutableArray alloc] init];
}

/**
 * Getter for locHandler property.
 * @return LocationHandler property to return.
 */
- (LocationHandler*)locHandler
{
    if (_locHandler == nil)
    {
        _locHandler = [[LocationHandler alloc] init];
        _locHandler.delegate = self;
    }
    return _locHandler;
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
    [self setLocationPoints:nil];
    [self setLocHandler:nil];
    [self setMapView:nil];
    [self setListButton:nil];
    [self setLocateButton:nil];
    [self setDashboardView:nil];
    [self setStartButton:nil];
    [self setStopButton:nil];
    [self setCurrentSpeedLabel:nil];
    [self setAvgSpeedLabel:nil];
    [self setMaxSpeedLabel:nil];
    [self setDurationLabel:nil];
    [self setDistanceLabel:nil];
}

- (void)viewDidUnload {
    [self setCurrentSpeedImage:nil];
    [super viewDidUnload];
}
@end
