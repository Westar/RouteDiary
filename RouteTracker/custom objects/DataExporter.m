//
//  DataExporter.m
//  RouteTracker
//

#import "DataExporter.h"
#import "LocationPoint.h"

@interface DataExporter ()
@property (nonatomic, strong) NSString *currentFilePath;
@end

@implementation DataExporter

/**
 * Init method of DataExporter. Sets the parent view controller and copies the routes to it's own array.
 * @param routes array of routes to be exported
 * @param parentVC parent view controller
 * @return id self
 */
- (id)initWithRoutes:(NSArray*)routes andParent:(UIViewController*)parentVC
{
    self = [super init];
    if (self)
    {
        self.parentViewController = parentVC;
        self.routesArray = [[NSMutableArray alloc] initWithArray:routes];
    }
    return self;
}

/**
 * Creates the gpf files into a dataArray. With a for iteration, it goes through the routesArray and creates the gpx files and the filnames, which then
 * added to a dictionary which is added to the return array.
 * @return NSArray array that contains the gpx files.
 */
- (NSArray*)createGPXFilesFromArray
{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (Route *route in self.routesArray)
    {
        self.currentFilePath = [self gpxFilePath];
        NSData *data = [NSData dataWithContentsOfFile:[self createGPXfileFromRoute:route]];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[data, [self.currentFilePath lastPathComponent]] forKeys:@[@"data", @"fileName"]];
        [dataArray addObject:dict];
    }
    return dataArray;
}

/**
 * Exports all the files that has been created and put them into an email as an attachement.
 */
- (void)exportViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        UIAlertView *loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.frame = CGRectMake(125.0, 50.0, 30.0, 30.0);
        [indicator startAnimating];
        [loadingAlert addSubview:indicator];
        [loadingAlert show];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            NSArray *dataArray = [self createGPXFilesFromArray];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"GPX export"];
                [mailer setMessageBody:@"My recent route in GPX format." isHTML:NO];
                for (NSDictionary *dict in dataArray)
                {
                    [mailer addAttachmentData:[dict objectForKey:@"data"] mimeType:@"application/gpx+xml" fileName:[dict objectForKey:@"fileName"]];
                }
                [self.parentViewController presentViewController:mailer animated:YES completion:nil];

            });
        });
    }
}

/**
 * Delegate method of composing an email. If the email has been sent, refresh all the objects that were sent and update their uploaded property to YES.
 * @param controller controller that responsible for sending the email.
 * @param result what happened during sending.
 * @param error Error to handle.
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email saved"
                                                            message:@"You can find it in the drafts folder."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
        case MFMailComposeResultSent:
        {

            break;
        }
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"An error occured while sending your message."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - exporting
/**
 * Create a name for the file
 * @return NSString return the name of the file
 */
- (NSString *)gpxFilePath
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];

    NSString *fileName = [NSString stringWithFormat:@"myroute_%@.gpx", dateString];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

/**
 * Creates a GPX format file from the location points.
 * @return NSString path to the file to be exported
 */
- (NSString*)createGPXfileFromRoute:(Route*)route
{
    GPXRoot *gpx = [GPXRoot rootWithCreator:@"RouteDiary"];
    GPXTrack *gpxTrack = [gpx newTrack];
    gpxTrack.name = @"New Route";

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [[route.locationPoints allObjects] sortedArrayUsingDescriptors:sortDescriptors];

    for (LocationPoint *locationPoint in sortedArray)
    {
        Route *route = (Route*)locationPoint.route;
        GPXTrackPoint *gpxTrackPoint = [gpxTrack newTrackpointWithLatitude:locationPoint.latitude.floatValue
                                                                 longitude:locationPoint.longitude.floatValue];
        gpxTrackPoint.elevation = locationPoint.altitude.floatValue;
        gpxTrackPoint.time = route.startTime;
    }

    NSString *gpxString = gpx.gpx;
    NSError *error;
    NSString *filePath = self.currentFilePath;
    if (![gpxString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        if (error)
        {
            NSLog(@"error, %@", error);
        }
        return nil;
    }
    return filePath;
}

@end
