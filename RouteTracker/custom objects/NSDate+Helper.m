//
//  NSDate+Helper.m
//  RouteTracker
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

/**
 * Check if date is today
 * @return BOOL if YES, the date is today.
 */
- (BOOL)isDateToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];

    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *passedDate = [cal dateFromComponents:components];

    if([today isEqualToDate:passedDate])
    {
        return YES;
    }
    return NO;
}

/**
 * Check if date is yesterday
 * @return BOOL if YES, the date is yesterday.
 */
- (BOOL)isDateYesterday
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - 86400;
	NSDate *yesterday = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];

    NSTimeInterval interval = [self timeIntervalSinceDate:yesterday];
    if (interval > 0)
    {
        return YES;
    }
    return NO;
}

@end
