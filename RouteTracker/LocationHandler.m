//
//  LocationHandler.m
//  SpeedTracker
//

#import "LocationHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation LocationHandler

/**
 * Start the location update.
 */
- (void)startLocationUpdate
{
    if ([idleTimer isValid]) {
        [idleTimer invalidate];
        idleTimer = nil;
    }
    [self.locationManager startUpdatingLocation];
}

/**
 * Put the location updates to an idle state to save battery.
 */
- (void)idleLocationUpdate
{
    [self stopTimer];
    self.locationManager.distanceFilter = 5.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
}

/**
 * Stop the timer.
 */
- (void)stopTimer
{
    if ([idleTimer isValid]) {
        [idleTimer invalidate];
        idleTimer = nil;
    }
}

/**
* Special getter method to initialize locationManager object (the current location manager, that manages location changes)
*/
- (CLLocationManager*)locationManager
{
    if (_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = 1.0;
        [_locationManager requestAlwaysAuthorization];
    }
    return _locationManager;
}

#pragma mark - location & map methods
/**
 Tells the delegate that the authorization status for the application changed.
 This method is called whenever the application’s ability to use location services changes. Changes can occur because the user allowed or denied the use of location services for your application or for the system as a whole.
 @param manager The location manager object reporting the event.
 @param status The new authorization status for the application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TRACKING_NOT_ALLOWED", nil)
                                                            message:NSLocalizedString(@"TRACKING_NOT_ALLOWED_MESSAGE", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        [self idleLocationUpdate];
	}
    else if(status == kCLAuthorizationStatusAuthorized)
    {
        if (_locationManager != nil)
        {
            [self startLocationUpdate];
        }
    }
}

/**
 Tells the delegate that the location manager was unable to retrieve a location value.
 Implementation of this method is optional. You should implement this method, however.
 If the location service is unable to retrieve a location right away, it reports a kCLErrorLocationUnknown error and keeps trying. In such a situation, you can simply ignore the error and wait for a new event. Also stops updating location informations, and starts a timer which counts back from 10 seconds, if reaches 0, it will try to start getting location informations.
 If the user denies your application’s use of the location service, this method reports a kCLErrorDenied error. Upon receiving such an error, you should stop the location service.
 If a heading could not be determined because of strong interference from nearby magnetic fields, this method returns kCLErrorHeadingFailure.
 @param manager The location manager object that was unable to retrieve the location.
 @param error The error object containing the reason the location or heading could not be retrieved.
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(error.code == kCLErrorDenied)
    {
        [self idleLocationUpdate];
    }
    else if(error.code == kCLErrorLocationUnknown)
    {
        [self idleLocationUpdate];
        idleTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                     target:self
                                                   selector:@selector(startLocationUpdate)
                                                   userInfo:nil
                                                    repeats:NO];
    }
}

/**
 This method is responsible for calculating latitude, longitude, altitude, speed and maximum speed values and pass these to the specified label's of mainViewController (parentController).
 
 @param manager The location manager object that generated the update event.
 @param newLocation The new location data.
 @param oldLocation The location data from the previous update. If this is the first update event delivered by this location manager, this parameter is nil. 
*/
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = abs([eventDate timeIntervalSinceNow]);

    if((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && (newLocation.coordinate.longitude != oldLocation.coordinate.longitude))
        locationChanged = YES;
    else
        locationChanged = NO;
    if ((howRecent < 5.0) && ( (newLocation.horizontalAccuracy < (oldLocation.horizontalAccuracy - 10.0))
                              || (newLocation.horizontalAccuracy < 30.0)
                              || ((newLocation.horizontalAccuracy <= 150.0) && locationChanged)))
    {
        self.userLocation = newLocation;
        self.currentSpeed = newLocation.speed;
        if ([self.delegate respondsToSelector:@selector(updateLabelsWithLocationData:andDistanceDelta:)])
        {
            CLLocationDistance delta = [newLocation distanceFromLocation:oldLocation];
            [self.delegate updateLabelsWithLocationData:self.userLocation andDistanceDelta:delta];
        }
    }
}

/**
 * Dealloc method to deallocate any references or allocations
 */
- (void)dealloc
{
    [self setUserLocation:nil];
    [self setLocationManager:nil];
}

@end
