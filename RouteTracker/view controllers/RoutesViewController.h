//
//  RoutesViewController.h
//  RouteTracker
//

/**
 * Class to display all routes in a tableView.
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RouteCell.h"

@interface RoutesViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, RouteCellDelegate>

/// tableView to use for displaying the routes
@property (nonatomic, weak) IBOutlet UITableView *routesTableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
/// image to display if no routes available in the list
@property (nonatomic, weak) IBOutlet UIImageView *noItemImage;

- (IBAction)goBack;
/**
 * Export the selected routes via dataexporter.
 * @return IBAction action
 */
- (IBAction)exportSelectedRoutes;

@end
