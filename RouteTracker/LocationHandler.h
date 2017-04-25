//
//  LocationHandler.h
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/**
 * Delegate protocol to update the labels for the delegate classes
 */
@protocol LocationHandlerDelegate <NSObject>
/**
 * Delegate method to update labels with new location info.
 * @param location new location
 * @param distanceDelta new distance
 */
- (void)updateLabelsWithLocationData:(CLLocation*)location andDistanceDelta:(CLLocationDistance)distanceDelta;
@end

/** This class handles all core location changes. So every time a new location is available, the iPhone's/iPod's/iPad's built in GPS device sends a notification to the CLLocationManagerDelegate, which handles all these changes in the specified methods. This class imports CoreLocation framework, to handle GPS changes, and also MainViewController so that it is able to update the MainViewController's label's text.
 */

@interface LocationHandler : NSObject <CLLocationManagerDelegate>
{
    //@param idleTimer timer that counts back from 10 seconds to reload locationManager if possible
    NSTimer *idleTimer;
    //@param locationChanged variable that tells whether location is changed or not since the last one
    BOOL locationChanged;
}

/// delegate to talk to other classes
@property (nonatomic, assign) id <LocationHandlerDelegate> delegate;
/// the current location of the user
@property (nonatomic, strong) CLLocation *userLocation;
///variable to hold current speed
@property (nonatomic) float currentSpeed;
///variable to store maximum Speed
@property (nonatomic) float maxSpeed;

@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)startLocationUpdate;
- (void)idleLocationUpdate;

@end
