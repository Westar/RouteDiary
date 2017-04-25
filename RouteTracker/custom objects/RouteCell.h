//
//  RouteCell.h
//  RouteTracker
//

#import <UIKit/UIKit.h>

@class Route;

/**
 * Delegate protocol to communicate to other classes.
 */

@protocol RouteCellDelegate <NSObject>
/**
 * Delegate method to delete a route at indexpath
 * @param indexPath path to delete at
 */
- (void)deleteRouteAtIndexPath:(NSIndexPath*)indexPath;
/**
 * Delegate method to select a route at indexpath
 * @param indexPath path to select at
 */
- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath;
/**
 * Delegate method to remove the route from the array at the indexpath.
 * @param indexPath path to select at
 */
- (void)removeRouteFromArrayAtIndexPath:(NSIndexPath*)indexPath;
@end

/**
 * Custom cell to display route informations in a tableView
 */

@interface RouteCell : UITableViewCell <UIGestureRecognizerDelegate>

/// indexpath for the cell
@property (strong, nonatomic) NSIndexPath *indexPath;
/// delegate to communicate with other classes
@property (nonatomic, assign) id <RouteCellDelegate> delegate;
/// label to display the total duration of the route
/// @property (nonatomic, strong) UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

/// label to display the total distance of the route
/// @property (nonatomic, strong) UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

/// label to display avg speed
/// @property (nonatomic, strong) UILabel *avgSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgSpeedLabel;

/// label to display max speed
/// @property (nonatomic, strong) UILabel *maxSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxSpeedLabel;

/// view to make the cell customized
@property (nonatomic, strong) UIView *backView;

- (void)setindexPathForCell:(NSIndexPath*)indexP;

@end
