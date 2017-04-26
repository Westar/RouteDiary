//
//  RoutesViewController.m
//  RouteTracker
//

#import "RoutesViewController.h"
#import "CoreDataHandler.h"
#import "Route.h"
#import "RouteCell.h"
#import "RouteDetailViewController.h"
#import "NSDate+Helper.h"
#import "DataExporter.h"

#define isMiles [[NSUserDefaults standardUserDefaults] boolForKey:@"isMiles"]

@interface RoutesViewController ()
/// dataexporter
@property (nonatomic, strong) DataExporter *dataExp;
/// the routes to be exported
@property (nonatomic, strong) NSMutableArray *routesToExport;
@end

@implementation RoutesViewController

/**
 * Sets the fetchController to be able to fetch data from Core Data
 * @return NSFetchedResultsController fetchResultsController
 */
- (NSFetchedResultsController*)fetchController
{
    if (_fetchController == nil)
    {
        NSManagedObjectContext *context = [[CoreDataHandler sharedInstance] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];

        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime"
                                                                       ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];

        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:context
                                                                 sectionNameKeyPath:@"sortDate"
                                                                          cacheName:nil];
        _fetchController.delegate = self;
    }
    return _fetchController;
}

/**
 * Dismiss the view
 * @return IBAction action
 */
- (IBAction)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.routesTableView beginUpdates];
}

/**
 * Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update. The fetched results controller reports changes to its section before changes to the fetch result objects.
 * @param controller The fetched results controller that sent the message.
 * @param anObject The object in controller’s fetched results that changed.
 * @param indexPath The index path of the changed object (this value is nil for insertions).
 * @param type The type of change. For valid values see “NSFetchedResultsChangeType”.
 * @param newIndexPath The destination path for the object for insertions or moves (this value is nil for a deletion).
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.routesTableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:(RouteCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
    }
    if ([[self.fetchController fetchedObjects] count] == 0)
    {
        //display an empty indicator image
        [self.noItemImage setHidden:NO];
        [self.routesTableView setHidden:YES];
    }
    else
    {
        [self.noItemImage setHidden:YES];
        [self.routesTableView setHidden:NO];
        [self.routesTableView reloadData];
    }
}

/**
 * Notifies the receiver of the addition or removal of a section. The fetched results controller reports changes to its section before changes to the fetched result objects.
 * @param controller The fetched results controller that sent the message.
 * @param sectionInfo The section that changed.
 * @param sectionIndex The index of the changed section.
 * @param type The type of change (insert or delete). Valid values are NSFetchedResultsChangeInsert and NSFetchedResultsChangeDelete.
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.routesTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
            break;

        case NSFetchedResultsChangeDelete:
            [self.routesTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
            break;
    }
}

/**
 * Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.routesTableView endUpdates];
}

/***
 * Asks the delegate for the height to use for a row in a specified location.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path that locates a row in tableView.
 * @return GGFloat A floating-point value that specifies the height (in points) that row should be.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

/**
 * A custom header view for the given section.
 * @param section which section
 * @param tableView tableView
 * @return UIView header view
 */
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 25.0)];
    //[view setBackgroundColor:[UIColor clearColor]];
    //[view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 7.0, 115.0, 25.0)];
    [image setBackgroundColor:[UIColor clearColor]];    
    [image setImage:[UIImage imageNamed:@"headerView.png"]];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 4.0, 90.0, 20.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithRed:141.0 green:62.0 blue:68.0 alpha:1.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setNumberOfLines:0];
    [label setText:[self titleForHeaderViewForSection:section]];
    [label setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:16.0]];

    [image addSubview:label];
    [view addSubview:image];
    return view;
}

/**
 * Create the title for the header view in a given section.
 * @param section section
 * @return NSString title to return
 */
- (NSString*)titleForHeaderViewForSection:(NSInteger)section
{
    Route *route = [self.fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSDate *currentDate = route.startTime;
    if ([currentDate isDateToday])
    {
        return @"Today";
    }
    else if ([currentDate isDateYesterday])
    {
        return @"Yesterday";
    }
    else
    {
        return [[[self.fetchController sections] objectAtIndex:section] name];
    }
}

/**
 * Asks the delegate for the height to use for the header of a particular section.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section of tableView.
 * @return CGFloat height of the header
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

/**
 * Tells the data source to return the number of rows in a given section of a table view. (required)
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return NSInteger The number of rows in section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if ([[self.fetchController sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

/**
 * Asks the data source to return the number of sections in the table view.
 * @param tableView An object representing the table view requesting this information.
 * @return NSInteger The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchController sections] count];
}

/**
 * Sets the title for the given section.
 * @param tableView An object representing the table view requesting this information.
 * @param section section to set the title to.
 * @return NSString Title of the header for the current section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.fetchController sections] objectAtIndex:section] name];
}

/**
 * Asks the data source for a cell to insert in a particular location of the table view.
 * @param tableView An object representing the table view requesting this information.
 * @param indexPath An index path locating a row in tableView.
 * @return RouteCell An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
 */
- (RouteCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCell *cell = (RouteCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[RouteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell setindexPathForCell:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/**
 * Configure a given cell to display the name of the category.
 * @param cell a cell t configure
 * @param indexPath An index path locating a row in tableView.
 */
- (void)configureCell:(RouteCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Route *route = [self.fetchController objectAtIndexPath:indexPath];
    int duration = [route.duration intValue];
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = (duration / 3600);
    [cell.durationLabel setText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds]];
    
    if (isMiles) {
        [cell.distanceLabel setText:[NSString stringWithFormat:@"%.2f miles", [route.distance floatValue] / 1000.0 * 0.62137119]];
        [cell.avgSpeedLabel setText:[NSString stringWithFormat:@"avg. speed: %.0f mph", [route.avgSpeed floatValue] * 0.62137119]];
        [cell.maxSpeedLabel setText:[NSString stringWithFormat:@"max. speed: %.0f mph", [route.maxSpeed floatValue] * 0.62137119]];
    
    } else {
        [cell.distanceLabel setText:[NSString stringWithFormat:@"%.2f km", [route.distance floatValue] / 1000.0]];
        [cell.avgSpeedLabel setText:[NSString stringWithFormat:@"avg. speed: %.0f km/h", [route.avgSpeed floatValue]]];
        [cell.maxSpeedLabel setText:[NSString stringWithFormat:@"max. speed: %.0f km/h", [route.maxSpeed floatValue]]];
    }
}

/**
 * Tells the delegate that the specified row can be edited or not.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/**
 * RouteCell's delegate method, to delete the route at the given indexPath.
 * @param route route to delete
 * @param indexPath which cell to delete
 */
- (void)deleteRouteAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *routeToDelete = (Route*)[self.fetchController objectAtIndexPath:indexPath];
    [[[CoreDataHandler sharedInstance] managedObjectContext] deleteObject:routeToDelete];
    [[CoreDataHandler sharedInstance] saveWithCompletionBlock:^{
    }];
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath
{
     Route *route = [self.fetchController objectAtIndexPath:indexPath];
    [self.routesToExport addObject:route];
}

- (void)removeRouteFromArrayAtIndexPath:(NSIndexPath *)indexPath
{
     Route *route = [self.fetchController objectAtIndexPath:indexPath];
    [self.routesToExport removeObject:route];
}

/**
 * Export the selected routes via dataexporter.
 * @return IBAction action
 */
- (IBAction)exportSelectedRoutes
{
    if ([self.routesToExport count] != 0)
    {
        self.dataExp = [[DataExporter alloc] initWithRoutes:self.routesToExport andParent:self];
        [self.dataExp exportViaEmail];
    }
}

/**
 * Tells the delegate that the specified row is now selected. Open the selected category and load it's items with a nice animation.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Route *route = [self.fetchController objectAtIndexPath:indexPath];
    RouteDetailViewController *detailVC = [[RouteDetailViewController alloc] initWith:route];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - view methods
/**
 * Load category entities from core data.
 */
- (void)loadCoreDataEntities
{
    NSError *error = nil;
    if (![self.fetchController performFetch:&error])
    {
        NSLog(@"Error %@, %@", error, [error userInfo]);
    }
    if ([[self.fetchController fetchedObjects] count] == 0)
    {
        //display an empty indicator image
        [self.noItemImage setHidden:NO];
        [self.routesTableView setHidden:YES];
    }
    else
    {
        [self.noItemImage setHidden:YES];
        [self.routesTableView setHidden:NO];
        [self.routesTableView reloadData];
    }
}

/**
 * Handle the save notification.
 * @param aNotification notification to handle.
 */
- (void)handleSaveNotification:(NSNotification *)aNotification
{
    NSManagedObjectContext *ctx = [[CoreDataHandler sharedInstance] managedObjectContext];
    [ctx mergeChangesFromContextDidSaveNotification:aNotification];
}

#pragma mark - view methods
/**
 * Load entities from core data, and set the background of the view
 */
- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    [self loadCoreDataEntities];
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
    
   // [self.view setBackgroundColor:RGB(250.0, 250.0, 250.0)];
    self.routesToExport = [[NSMutableArray alloc] init];
}

/**
 * When view did apper add obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSManagedObjectContext *ctx = [[CoreDataHandler sharedInstance] managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:ctx];
}

/**
 * When view did disappear remove obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSManagedObjectContext *ctx = [[CoreDataHandler sharedInstance] managedObjectContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:ctx];
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
    [self setRoutesTableView:nil];
    [self setFetchController:nil];
}

@end
