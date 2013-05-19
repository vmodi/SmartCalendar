//
//  HorizontalScrollerDateView.m
//  smarty
//
//  Created by Vishal Modi on 3/2/13.
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "HorizontalScrollerDateView.h"
#import "UIColorExt.h"

@interface HorizontalScrollerDateView()
@property (copy) NSDate* cellDate;

@end

@implementation HorizontalScrollerDateView
@synthesize dateLabel, dayLabel;
@synthesize cellDate;
@synthesize isActive;

static NSDateFormatter *dayFormatter;
static NSDateFormatter *dateNumFormatter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDateFormatter];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setDateFormatter];
    }
    return self;
}

- (void) setDateFormatter{
    dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEE"];
    
    dateNumFormatter = [[NSDateFormatter alloc] init];
    [dateNumFormatter setDateFormat:@"dd"];    
}

-(void) populateCellWithDate:(NSDate*)date{
    self.cellDate = date;
    self.dayLabel.text = [dayFormatter stringFromDate:date];
    self.dateLabel.text = [dateNumFormatter stringFromDate:date];
}

-(void) currentStateSelected:(Boolean)selected{
    if(selected){
        self.backgroundColor = [UIColor blueColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
