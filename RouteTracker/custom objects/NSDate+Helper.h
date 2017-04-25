//
//  NSDate+Helper.h
//  RouteTracker
//

/**
 * Category for nsdate, to know if date was yesterday or today.
 */

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (BOOL)isDateYesterday;
- (BOOL)isDateToday;

@end
