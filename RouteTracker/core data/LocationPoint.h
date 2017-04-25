//
//  LocationPoint.h
//  RouteTracker
//

/**
 * Core Data object to store all the route coordinates.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocationPoint : NSManagedObject

/// altitude value of the coordinate
@property (nonatomic, retain) NSNumber * altitude;
/// latitude value of the coordinate
@property (nonatomic, retain) NSNumber * latitude;
/// longitude value of the coordinate
@property (nonatomic, retain) NSNumber * longitude;
/// timestamp of the coordinate
@property (nonatomic, retain) NSNumber * timestamp;
/// the object's owner
@property (nonatomic, retain) NSManagedObject *route;

@end
