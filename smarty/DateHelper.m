//
//  DateHelper.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper
static NSDateFormatter *monthYearDateFormatter;

+(NSArray *) getMonthGridDatesForDate:(NSDate *) currentDate{
    if (currentDate) {
        NSDate* firstDateOfMonth = [currentDate monthDate];
        TKDateInformation firstDateOfMonthInfo = [firstDateOfMonth dateInformation];
        NSDate *firstDateOfMonthGrid = [firstDateOfMonth dateByAddingDays:(1 - firstDateOfMonthInfo.weekday)];
        
        NSDate *lastDateOfMonth = [currentDate lastOfMonthDate];
        TKDateInformation lastDateOfMonthInfo = [lastDateOfMonth dateInformation];
        NSDate *lastDateOfMonthGrid = [lastDateOfMonth dateByAddingDays:(7 - lastDateOfMonthInfo.weekday)];
        
        return [NSArray arrayWithObjects:firstDateOfMonthGrid, lastDateOfMonthGrid, nil];
        
    }
    return nil;
}

+(NSArray *) getWeekDatesForDate:(NSDate *) currentDate{
    if (currentDate) {
        NSDate* firstDateOfWeek = [currentDate dateByAddingDays:-7];
        NSDate *lastDateOfWeek= [currentDate dateByAddingDays:7];
        
        return [NSArray arrayWithObjects:firstDateOfWeek, lastDateOfWeek, nil];        
    }
    return nil;
}

+(NSString *) getDateInMonDdYyyy:(NSDate *)date{
    if (!monthYearDateFormatter){
        monthYearDateFormatter = [[NSDateFormatter alloc] init];
        [monthYearDateFormatter setDateFormat:@"MMMM dd, yyyy"];
    }
    return [monthYearDateFormatter stringFromDate:date];
}

@end
