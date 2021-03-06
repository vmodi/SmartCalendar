/*
     File: InfiniteScrollView.m 
 */

#import "InfiniteScrollView.h"
#import "HorizontalScrollerDateView.h"
#import "DateHelper.h"

@interface InfiniteScrollView () {
    NSMutableArray *visibleDateViews;
    NSDate         *startDate;
    NSMutableArray *reuseDateCellsStorage;
    id<DateScrollerDelegate> dateScrollerDelegate;
    HorizontalScrollerDateView *selectedDateView;
}

- (void)tileDatesFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX;

@end


@implementation InfiniteScrollView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.contentSize = CGSizeMake(5000, self.frame.size.height);
        
        visibleDateViews = [[NSMutableArray alloc] init];
        reuseDateCellsStorage = [[NSMutableArray alloc] init];
        
        [self setShowsHorizontalScrollIndicator:NO];
    }
    return self;
}

#pragma mark -
#pragma mark Layout

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for (HorizontalScrollerDateView *label in visibleDateViews) {
            CGPoint center = label.center;
            center.x += (centerOffsetX - currentOffset.x);
            label.center = center;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(!self.hidden){
        [self updateScrollView];
    }
}

-(void) updateScrollView{
    [self recenterIfNecessary];
    
    // tile content in visible bounds
    CGRect visibleBounds = [self bounds];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    [self tileDatesFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

#pragma mark - public methods
-(void) prepareScrollerWithDate:(NSDate *)date withDelegate:(id<DateScrollerDelegate>)delegate{
    [visibleDateViews removeAllObjects];
    startDate = date;
    dateScrollerDelegate = delegate;
    [self updateScrollView];
}

-(void) setCurrentSelectedDate:(NSDate *)date{
    NSLog(@"setting selected date = %@", [date description]);
    if (selectedDateView && [DateHelper compareDateIgnoretime:selectedDateView.cellDate withDate:date]){
        return;
    }
    if(selectedDateView){
        [selectedDateView currentStateSelected:NO];
        selectedDateView = nil;
    } 
    for (HorizontalScrollerDateView *dateView in visibleDateViews) {
        if ([DateHelper compareDateIgnoretime:dateView.cellDate withDate:date]) {
            selectedDateView = dateView;
            [selectedDateView currentStateSelected:YES];
        }
    }
    if(selectedDateView){
        int selectedCellLeftEdge = selectedDateView.frame.origin.x;
        int selectedCellRightEdge = selectedDateView.frame.origin.x + selectedDateView.frame.size.width;
        int updateOffsetBy = 0;
        int scrollViewRightEdge = self.contentOffset.x + self.bounds.size.width;
        if (selectedCellLeftEdge < self.contentOffset.x) {
            updateOffsetBy = selectedCellLeftEdge - self.contentOffset.x;
        } else if (selectedCellRightEdge > self.contentOffset.x + self.bounds.size.width){
            updateOffsetBy =  selectedCellRightEdge - scrollViewRightEdge;
        }
        if(updateOffsetBy){
            [self setContentOffset:CGPointMake(self.contentOffset.x + updateOffsetBy, self.contentOffset.y) animated:YES];
        }
    } else {
        HorizontalScrollerDateView *firstVisibleDateView = [visibleDateViews objectAtIndex:0];
        HorizontalScrollerDateView *lastVisibleDateView = [visibleDateViews lastObject];
        int updateOffsetBy = 0;
        if ([date compare:firstVisibleDateView.cellDate] == NSOrderedAscending) {
            int daysDiff = [DateHelper daysBetweenDate:date andDate:firstVisibleDateView.cellDate];
            
            int selectedCellLeftEdge = firstVisibleDateView.frame.origin.x - (daysDiff * firstVisibleDateView.frame.size.width);
            
            updateOffsetBy = selectedCellLeftEdge - self.contentOffset.x;
            
        } else {
            int daysDiff = [DateHelper daysBetweenDate:lastVisibleDateView.cellDate andDate:date];
            
            int scrollViewRightEdge = self.contentOffset.x + self.bounds.size.width;
            int selectedCellRightEdge = lastVisibleDateView.frame.origin.x + ((daysDiff + 1) * lastVisibleDateView.frame.size.width);
            updateOffsetBy =  selectedCellRightEdge - scrollViewRightEdge;

        }
        
        [self setContentOffset:CGPointMake(self.contentOffset.x + updateOffsetBy, self.contentOffset.y) animated:YES];
    }
}

#pragma mark - Date Tiling

- (HorizontalScrollerDateView*) getDateView{
    HorizontalScrollerDateView *dateView;
    if (reuseDateCellsStorage.count) {
        for (HorizontalScrollerDateView *reuseDateView in reuseDateCellsStorage){
            if (!reuseDateView.isActive) {
                reuseDateView.isActive = YES;
                return reuseDateView;
            }
        }
    }
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HorizontalScrollerDateView" owner:self options:nil];
    id firstObject = [topLevelObjects objectAtIndex:0];
    if ([firstObject isKindOfClass:[HorizontalScrollerDateView class]]) {
        dateView = firstObject;
    } else {
        dateView = [topLevelObjects objectAtIndex:1];
    }
    dateView.isActive = YES;
    [reuseDateCellsStorage addObject:dateView];
    return dateView;
}

- (HorizontalScrollerDateView *)insertScrollerDateView {
    HorizontalScrollerDateView *dateView = [self getDateView];
    [self addSubview:dateView];
    return dateView;
}

- (CGFloat)placeNewDateOnRight:(CGFloat)rightEdge {
    HorizontalScrollerDateView *dateView = [self insertScrollerDateView];
    NSDate* dateForCell;
    if(!visibleDateViews.count){
        dateForCell = startDate;
    } else {
        dateForCell = ((HorizontalScrollerDateView *)[visibleDateViews lastObject]).cellDate;
        dateForCell = [dateForCell dateByAddingDays:1];
    }
    [dateView populateCellWithDate:dateForCell];
    [visibleDateViews addObject:dateView]; // add rightmost date at the end of the array
    
    CGRect frame = [dateView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = 0;
    [dateView setFrame:frame];
        
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewDateOnLeft:(CGFloat)leftEdge {
    HorizontalScrollerDateView *dateView = [self insertScrollerDateView];
    NSDate* dateForCell;
    if(!visibleDateViews.count){
        dateForCell = startDate;
    } else {
        dateForCell = ((HorizontalScrollerDateView *)[visibleDateViews objectAtIndex:0]).cellDate;
        dateForCell = [dateForCell dateByAddingDays:-1];
    }
    [dateView populateCellWithDate:dateForCell];
    [visibleDateViews insertObject:dateView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [dateView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [dateView setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileDatesFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleDateViews count] == 0) {
        [self placeNewDateOnRight:minimumVisibleX];
    }
    
    // add dates that are missing on right side
    HorizontalScrollerDateView *lastDateView = [visibleDateViews lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastDateView frame]);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewDateOnRight:rightEdge];
    }
    
    // add dates that are missing on left side
    HorizontalScrollerDateView *firstDateView = [visibleDateViews objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX([firstDateView frame]);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewDateOnLeft:leftEdge];
    }
    
    // remove dates that have fallen off right edge
    lastDateView = [visibleDateViews lastObject];
    while ([lastDateView frame].origin.x > maximumVisibleX) {
        lastDateView.isActive = NO;
        [visibleDateViews removeLastObject];
        lastDateView = [visibleDateViews lastObject];
    }
    
    // remove dates that have fallen off left edge
    firstDateView = [visibleDateViews objectAtIndex:0];
    while (CGRectGetMaxX([firstDateView frame]) < minimumVisibleX) {
        firstDateView.isActive = NO;
        [visibleDateViews removeObjectAtIndex:0];
        firstDateView = [visibleDateViews objectAtIndex:0];
    }
    
    NSDate *dateInCenter = ((HorizontalScrollerDateView*)[visibleDateViews objectAtIndex:visibleDateViews.count/2]).cellDate;
    if (dateInCenter) {
    
    TKDateInformation centerDateInfo = [dateInCenter dateInformation];
        if(centerDateInfo.day == 1){
            if([dateScrollerDelegate respondsToSelector:@selector(monthChangedWithDateInfo:)]){
                [dateScrollerDelegate monthChangedWithDateInfo:dateInCenter];
            }
        }
    }
}

@end
