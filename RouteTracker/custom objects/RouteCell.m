//
//  RouteCell.m
//  RouteTracker
//

#import "RouteCell.h"

@interface RouteCell ()
{
    UIImageView *trashIcon;
    UILabel *trashLabel;
    UILabel *selectLabel;
    UIView *selectedLine;
    UIImageView *selectIcon;
}
/// the original center of the cell
@property (nonatomic) CGPoint originalCenter;
/// if YES, delete the cell on release
@property (nonatomic) BOOL deleteOnDragRelease;
/// if YES, select the cell on release
@property (nonatomic) BOOL selectOnDragRelease;
/// YES if the cell is selected for export
@property (nonatomic) BOOL selectedForExport;
@end

@implementation RouteCell

/**
 * Init method for the custom cell, where labels are set up.
 * @param style which style to use
 * @param reuseIdentifier identifier to use
 * @return id cell
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
        self.backView.backgroundColor = RGB(247.0, 243.0, 242.0);
/*
        UIView *topWhiteLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
        [topWhiteLine setBackgroundColor:[UIColor whiteColor]];
        [self.backView addSubview:topWhiteLine];
*/
        UIView *bottomgrayLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 69.5, 320.0, 0.5)];
        [bottomgrayLine setBackgroundColor:RGB(211.0, 211.0, 211.0)];
        [self.backView addSubview:bottomgrayLine];
        [self addSubview:self.backView];

        // adding the delete stuff
        //trashLabel = [self createNoteLabel];
        //[self addSubview:noteLabel];

        trashIcon = [self createTrashImageView];
        [self addSubview:trashIcon];

        //selectLabel = [self createSelectLabel];
        //[self addSubview:selectLabel];
        
        selectIcon = [self createSelectImageView];
        [self addSubview:selectIcon];

        selectedLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 4.0, CGRectGetHeight(self.backView.frame))];
        [selectedLine setBackgroundColor:RGB(120.0, 205.0, 198.0)];

        [self addRecognizer];

        [self setupLabels];
        [self addSubview:self.backView];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

/**
 * Create a trash icon in front of the note label under the cell
 * @return UIImageView icon to return
 */
- (UIImageView*)createSelectImageView
{
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectNull];
    image1.image = [UIImage imageNamed:@"checkColor.png"];
    return image1;
}

/**
 * Create a trash icon in front of the note label under the cell
 * @return UIImageView icon to return
 */
- (UIImageView*)createTrashImageView
{
    UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectNull];
    image2.image = [UIImage imageNamed:@"crossColor.png"];
    return image2;
}


/*
 * Create a note label under the cell
 * @return UILabel label to create
 
- (UILabel*)createTrashLabel
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:12.0];
    label.backgroundColor = [UIColor blackColor];
    label.text = @"Pull more to delete";
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    return label;
}
 */

/*
 * Create a select label under the cell
 * @return UILabel label to create

- (UILabel*)createSelectLabel
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:12.0];
    label.backgroundColor = [UIColor blackColor];
    label.text = @"Pull more to select";
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    return label;
}
  */



/**
 * Lays out subviews. Sets the frames of the trash icon and note label.
 */
- (void)layoutSubviews
{
    selectIcon.frame = CGRectMake(-320, 0, 320, 70.0);
    trashIcon.frame = CGRectMake(self.bounds.size.width, 0, 320.0, 70);
    
    
    //selectLabel.frame = CGRectMake(-295.0 -40, 0.0, 295.0, self.bounds.size.height);
    //trashLabel.frame = CGRectMake(25.0, 0.0, 295.0, self.bounds.size.height);
       
}

/**
 * Adds a gesture recognizer to recognize the swipe action
 */
- (void)addRecognizer
{
    UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
}

/**
 * Asks the view if the gesture recognizer should be allowed to continue tracking touch events.
 * @param gestureRecognizer recongizer
 * @return BOOL YES if the gesture recognizer should continue tracking touch events and use them to trigger a gesture or NO if it should transition to the UIGestureRecognizerStateFailed state.
 */
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y))
    {
        return YES;
    }
    return NO;
}

/**
 * Handle the swipe gesture on the cell. If user swiped long enough (half of the cell), than tell the delegate to call deleteRoute:atIndexPath: method
 * @param recognizer the recognizer who received the event
 */
-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // 1
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // if the gesture has just started, record the current centre location
        self.originalCenter = self.center;
    }
    
    // 2
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(self.originalCenter.x + translation.x, self.originalCenter.y);
        // determine whether the item has been dragged far enough to initiate a delete / complete
        self.deleteOnDragRelease = self.frame.origin.x < -self.frame.size.width / 2;
        self.selectOnDragRelease = self.frame.origin.x > self.frame.size.width / 2;
        
        // fade the contextual cues
        float cueAlpha = fabsf(self.frame.origin.x) / (self.frame.size.width / 2);
        selectIcon.alpha = cueAlpha;
        trashIcon.alpha = cueAlpha;
        
        
        trashIcon.image = (_deleteOnDragRelease ? [UIImage imageNamed:@"cross.png"] : [UIImage imageNamed:@"crossColor.png"]);
        
        
        if (self.selectedForExport)
            {
            selectIcon.image = (_selectOnDragRelease ? [UIImage imageNamed:@"checkColor.png"] : [UIImage imageNamed:@"check.png"]);
            }
        else
            {
            selectIcon.image = (_selectOnDragRelease ? [UIImage imageNamed:@"check.png"] : [UIImage imageNamed:@"checkColor.png"]);
            }
        selectLabel.textColor = (_selectOnDragRelease ? [UIColor orangeColor] : [UIColor darkGrayColor]);
    }

    // 3
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (!self.deleteOnDragRelease)
        {
            [self animateCellBack];
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(deleteRouteAtIndexPath:)])
            {
                [self.delegate deleteRouteAtIndexPath:self.indexPath];
            }
        }
        if (self.selectOnDragRelease)
        {
            if (self.selectedForExport)
            {
                if ([self.delegate respondsToSelector:@selector(removeRouteFromArrayAtIndexPath:)])
                {
                    [self.delegate removeRouteFromArrayAtIndexPath:self.indexPath];
                }
                [selectedLine removeFromSuperview];
                self.selectedForExport = NO;
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(selectCellAtIndexPath:)])
                {
                    [self.delegate selectCellAtIndexPath:self.indexPath];
                }
                [self.backView addSubview:selectedLine];
                [self addSubview:self.backView];
                self.selectedForExport = YES;
            }
        }
        else
        {
            [self animateCellBack];
        }
    }
}

/**
 * Animate the cell back to it's original frame.
 */
- (void)animateCellBack
{
    // the frame this cell would have had before being dragged
    CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
    // if the item is not being deleted or selected, snap back to the original location
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = originalFrame;
                     }
                     completion:nil];
}

/**
 * Sets the route object for the cell and the indexPath
 * @param indexP the indexpath of the cell
 */
- (void)setindexPathForCell:(NSIndexPath*)indexP
{
    self.indexPath = indexP;
}

/**
 * Identifier of the cell.
 * @return NSString identifier
 */
+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

/**
 * Sets the selected state of the cell, optionally animating the transition between states.
 * @param selected YES to set the cell as selected, NO to set it as unselected. The default is NO.
 * @param animated YES to animate the transition between selected states, NO to make the transition immediate.
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.backView.backgroundColor = RGB(120.0, 205.0, 198.0);
        self.backView.backgroundColor = [UIColor brownColor];
    }
    else
    {
        self.backView.backgroundColor = RGB(247.0, 243.0, 242.0);
        
    }
}

/**
 * Setup the labels for the cell.
 */
- (void)setupLabels
{
    self.durationLabel = [self createLabelForFrame:CGRectMake(10.0, 10.0, (self.frame.size.width / 2) - 20.0, 30.0)
                                          withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:35.0]
                                          andColor:[UIColor blackColor]];
    self.distanceLabel = [self createLabelForFrame:CGRectMake(self.frame.size.width / 2, 10.0, (self.frame.size.width / 2) - 20.0, 30.0)
                                          withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:35.0]
                                          andColor:[UIColor blackColor]];
    [self.distanceLabel setTextAlignment:NSTextAlignmentRight];
    
    self.avgSpeedLabel = [self createLabelForFrame:CGRectMake(10.0, self.distanceLabel.frame.size.height + 10.0, (self.frame.size.width / 2) - 20.0, 20.0)
                                          withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:14.0]
                                          andColor:[UIColor lightGrayColor]];
    self.maxSpeedLabel = [self createLabelForFrame:CGRectMake(self.frame.size.width / 2, self.distanceLabel.frame.size.height + 10.0, (self.frame.size.width / 2) - 20.0, 20.0)
                                          withFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:14.0]
                                          andColor:[UIColor lightGrayColor]];
    [self.maxSpeedLabel setTextAlignment:NSTextAlignmentRight];

    [self.backView addSubview:self.durationLabel];
    [self.backView addSubview:self.distanceLabel];
    [self.backView addSubview:self.avgSpeedLabel];
    [self.backView addSubview:self.maxSpeedLabel];
}

/**
 * Create a label for the given frame, font and color.
 * @param frame frame to use
 * @param font font to use
 * @param color color to use
 * @return UILabel return the created label
 */
- (UILabel*)createLabelForFrame:(CGRect)frame withFont:(UIFont*)font andColor:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = frame;
    label.textColor = color;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.minimumFontSize = 9.0;
    return label;
}

@end
