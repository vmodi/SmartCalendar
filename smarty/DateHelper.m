//
//  DateHelper.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

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

@end