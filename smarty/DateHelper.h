//
//  DateHelper.h
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+TKCategory.h"
#import "NSDate+CalendarGrid.h"

@interface DateHelper : NSObject
+(NSArray *) getMonthGridDatesForDate:(NSDate *) currentDate;
+(NSArray *) getWeekDatesForDate:(NSDate *) currentDate;
+(NSString *) getDateInMonDdYyyy:(NSDate *)date;
+(Boolean) compareDateIgnoretime:(NSDate*) date1 withDate:(NSDate*)date2;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
