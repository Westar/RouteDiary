//
//  Route.h
//  RouteTracker
//

/**
 * Route object to store all the information about the route.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocationPoint;

@interface Route : NSManagedObject

/// duration of the tracking
@property (nonatomic, retain) NSNumber * duration;
/// startTime the start time of the tracking
@property (nonatomic, retain) NSDate * startTime;
/// endTime end time of the tracking
@property (nonatomic, retain) NSDate * endTime;
/// avgSpeed average speed of the route
@property (nonatomic, retain) NSNumber * avgSpeed;
/// maxSpeed maximum speed of the route
@property (nonatomic, retain) NSNumber * maxSpeed;
/// distane distance of the route
@property (nonatomic, retain) NSNumber * distance;
/// date to make sorting in tableview easier
@property (nonatomic, retain) NSString * sortDate;
/// locationpoints to store
@property (nonatomic, retain) NSSet *locationPoints;
@end

@interface Route (CoreDataGeneratedAccessors)

/**
 * Add a new location object
 * @param value value to add
 */
- (void)addLocationPointsObject:(LocationPoint *)value;
/**
 * Remove location object
 * @param value value to remove
 */
- (void)removeLocationPointsObject:(LocationPoint *)value;
/**
 * Add a new location objects
 * @param values values to add
 */
- (void)addLocationPoints:(NSSet *)values;
/**
 * Remove location objects
 * @param values values to remove
 */
- (void)removeLocationPoints:(NSSet *)values;

@end
