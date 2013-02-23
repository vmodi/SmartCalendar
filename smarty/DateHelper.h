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
@end
