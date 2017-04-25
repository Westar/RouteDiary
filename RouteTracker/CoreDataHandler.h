//
//  CoreDataHandler.h
//

/**
 Class to handle all core data related stuff.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
/// core data managed object model
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataHandler*)sharedInstance;
- (void)saveWithCompletionBlock:(void(^)(void))completionBlock;
/**
 * Special getter for context property.
 * @return NSManagedObjectContext context to return.
 */
- (NSManagedObjectContext*)managedObjectContext;
- (void)saveRouteWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime duration:(int)duration points:(NSArray*)pointsArray avgSpeed:(float)avgSpeed maxSpeed:(float)maxSpeed distance:(float)distance withCompletionBlock:(void(^)(void))completionBlock;

@end
