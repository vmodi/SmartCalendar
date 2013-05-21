//
//  DateHelper.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper
static NSDateFormatter *monthYearDateFormatter;
static NSCalendar *calendar;
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

+(Boolean) compareDateIgnoretime:(NSDate*) date1 withDate:(NSDate*)date2{

    calendar = [NSCalendar currentCalendar];
    NSInteger desiredComponents = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    
    NSDateComponents *firstComponents = [calendar components:desiredComponents fromDate:date1];
    NSDateComponents *secondComponents = [calendar components:desiredComponents fromDate:date2];
    
    return (firstComponents.day == secondComponents.day && firstComponents.month == secondComponents.month && firstComponents.year == secondComponents.year);
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
