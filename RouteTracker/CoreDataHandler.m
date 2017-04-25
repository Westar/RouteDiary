//
//  CoreDataHandler.m
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "Route.h"
#import "LocationPoint.h"
#import "CoordinateObject.h"

@implementation CoreDataHandler
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _objectModel;

NSString * const kDataManagerBundleName = @"RouteTracker";
NSString * const kDataManagerModelName = @"RouteTracker";
NSString * const kDataManagerSQLiteName = @"RouteTracker.sqlite";

/**
 * This class is a singleton, so you only have to call alloc, init once and it's "available" for every class.
 * @return CoreDataHandler returns an instance of the class.
 */
+ (CoreDataHandler*)sharedInstance
{
	static dispatch_once_t pred;
	static CoreDataHandler *sharedInstance = nil;
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

/**
 * Special getter for object model.
 * @return NSManagedObjectModel model to return.
 */
- (NSManagedObjectModel*)objectModel
{
	if (_objectModel)
		return _objectModel;

	NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"RouteTracker" withExtension:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
	return _objectModel;
}

/**
 * Special getter for the persistent store coordinator property.
 * @return NSPersistentStoreCoordinator storecoordinator to return.
 */
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
		return _persistentStoreCoordinator;

	// Get the paths to the SQLite file
	NSURL *storeURL = [[self sharedDocumentsPath] URLByAppendingPathComponent:@"RouteTracker.sqlite"];

	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self objectModel]];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
	return _persistentStoreCoordinator;
}

/**
 * Special getter for context property.
 * @return NSManagedObjectContext context to return.
 */
- (NSManagedObjectContext*)managedObjectContext
{
	if (_managedObjectContext != nil)
		return _managedObjectContext;

	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _managedObjectContext;
	}

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
	return _managedObjectContext;
}

/**
 * Save all the chanes to core data.
 * @param completionBlock block to be called after successful save.
 */
- (void)saveWithCompletionBlock:(void(^)(void))completionBlock
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
    completionBlock();
}

/**
 * Return the document path.
 * @return NSURL path to return.
 */
- (NSURL*)sharedDocumentsPath
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - saving methods
/**
 * Save route object to Core Data.
 * @param startTime the start time of the tracking
 * @param endTime end time of the tracking
 * @param duration duration of the tracking
 * @param pointsArray array that contains all the coordinates of the route
 * @param avgSpeed average speed of the route
 * @param maxSpeed maximum speed of the route
 * @param distance distance of the route
 * @param completionBlock block to be called after successful save.
 */
- (void)saveRouteWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime duration:(int)duration points:(NSArray*)pointsArray avgSpeed:(float)avgSpeed maxSpeed:(float)maxSpeed distance:(float)distance withCompletionBlock:(void(^)(void))completionBlock
{
    Route *route = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route"
                                                                   inManagedObjectContext:self.managedObjectContext];
    [route setStartTime:startTime];
    [route setEndTime:endTime];
    [route setDuration:[NSNumber numberWithInt:duration]];
    [route setDistance:[NSNumber numberWithFloat:distance]];
    [route setAvgSpeed:[NSNumber numberWithFloat:avgSpeed]];
    [route setMaxSpeed:[NSNumber numberWithFloat:maxSpeed]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-YYYY"];
    [route setSortDate:[formatter stringFromDate:[NSDate date]]];

    for (int i = 0; i < [pointsArray count]; i++)
    {
        CoordinateObject *coordinateO = [pointsArray objectAtIndex:i];
        LocationPoint *locPoint = (LocationPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"LocationPoint"
                                                              inManagedObjectContext:self.managedObjectContext];
        [locPoint setLongitude:[NSNumber numberWithFloat:coordinateO.coord.longitude]];
        [locPoint setLatitude:[NSNumber numberWithFloat:coordinateO.coord.latitude]];
        [locPoint setTimestamp:[NSNumber numberWithDouble:coordinateO.timeStamp]];
        [locPoint setAltitude:[NSNumber numberWithFloat:coordinateO.elevation]];
        [route addLocationPointsObject:locPoint];
    }

    [self saveWithCompletionBlock:completionBlock];
}

@end
