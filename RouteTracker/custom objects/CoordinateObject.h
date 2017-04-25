//
//  CoordinateObject.h
//  RouteTracker
//

/**
 * Helper class to save coordinate point with timestamp.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoordinateObject : NSObject

/// coordinate to save
@property (nonatomic, assign) CLLocationCoordinate2D coord;
/// timestamp to save
@property (nonatomic) double timeStamp;
/// height of sea level at the coordinate
@property (nonatomic) float elevation;

@end
