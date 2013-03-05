/*
     File: InfiniteScrollView.m 
 */

#import "InfiniteScrollView.h"
#import "HorizontalScrollerDateView.h"
#import "NSDate+TKCategory.h"

@interface InfiniteScrollView () {
    NSMutableArray *visibleDates;
    NSDate         *startDate;
    NSMutableArray *reuseDateCellsStorage;
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX;

@end


@implementation InfiniteScrollView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.contentSize = CGSizeMake(5000, self.frame.size.height);
        
        visibleDates = [[NSMutableArray alloc] init];
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
        for (UILabel *label in visibleDates) {
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
    
    [self tileLabelsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

#pragma mark - public methods
-(void) prepareScrollerWithDate:(NSDate *)date{
    [visibleDates removeAllObjects];
    startDate = date;
    [self updateScrollView];
}

#pragma mark -
#pragma mark Label Tiling

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

- (HorizontalScrollerDateView *)insertLabel {
    HorizontalScrollerDateView *dateView = [self getDateView];
    [self addSubview:dateView];
    return dateView;
}

- (CGFloat)placeNewLabelOnRight:(CGFloat)rightEdge {
    HorizontalScrollerDateView *dateView = [self insertLabel];
    NSDate* dateForCell;
    if(!visibleDates.count){
        dateForCell = startDate;
    } else {
        dateForCell = ((HorizontalScrollerDateView *)[visibleDates lastObject]).cellDate;
        dateForCell = [dateForCell dateByAddingDays:1];
    }
    [dateView populateCellWithDate:dateForCell];
    [visibleDates addObject:dateView]; // add rightmost label at the end of the array
    
    CGRect frame = [dateView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = 0;
    [dateView setFrame:frame];
        
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewLabelOnLeft:(CGFloat)leftEdge {
    HorizontalScrollerDateView *dateView = [self insertLabel];
    NSDate* dateForCell;
    if(!visibleDates.count){
        dateForCell = startDate;
    } else {
        dateForCell = ((HorizontalScrollerDateView *)[visibleDates objectAtIndex:0]).cellDate;
        dateForCell = [dateForCell dateByAddingDays:-1];
    }
    [dateView populateCellWithDate:dateForCell];
    [visibleDates insertObject:dateView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [dateView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [dateView setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleDates count] == 0) {
        [self placeNewLabelOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    HorizontalScrollerDateView *lastDateView = [visibleDates lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastDateView frame]);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewLabelOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    HorizontalScrollerDateView *firstDateView = [visibleDates objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX([firstDateView frame]);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewLabelOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastDateView = [visibleDates lastObject];
    while ([lastDateView frame].origin.x > maximumVisibleX) {
//        [lastLabel removeFromSuperview];
        lastDateView.isActive = NO;
        [visibleDates removeLastObject];
        lastDateView = [visibleDates lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstDateView = [visibleDates objectAtIndex:0];
    while (CGRectGetMaxX([firstDateView frame]) < minimumVisibleX) {
//        [firstDateView removeFromSuperview];
        firstDateView.isActive = NO;
        [visibleDates removeObjectAtIndex:0];
        firstDateView = [visibleDates objectAtIndex:0];
    }
}

@end
