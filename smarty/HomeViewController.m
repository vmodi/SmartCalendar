//
//  HomeViewController.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "HomeViewController.h"
#import "UICalendarDateViewCell.h"
#import "DateHelper.h"
#import "UIColorExt.h"

@interface HomeViewController (){
	NSArray *marks;
    NSDateFormatter *monthYearDateFormatter;
    NSDate *selectedDate;
    TKDateInformation selectedDateInfo;
    BOOL isCollectionViewInWeekMode;
}
@property (strong,nonatomic) NSDate *monthDate;
@property (nonatomic,strong) NSArray *datesArray;
@end

@implementation HomeViewController
@synthesize monthGridView;
NSString *kCellID = @"calendarGridCellID";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isCollectionViewInWeekMode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"UICalendarDateViewCell" bundle:nil];
    [self.monthGridView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    
    self.monthGridView.dataSource = self;
    self.monthGridView.delegate = self;
    
    monthYearDateFormatter = [[NSDateFormatter alloc] init];
    [monthYearDateFormatter setDateFormat:@"MMMM yyyy"];

    [self prepareMonthGridForDate:[NSDate date]];
    [self updateWeekdayTitles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public methods



#pragma mark - private methods
-(void)prepareMonthGridForDate:(NSDate *) date{
    selectedDate = date;
    selectedDateInfo = [selectedDate dateInformation];
    self.datesArray = [DateHelper getMonthGridDatesForDate:date];
    self.monthGridTitle.text = [monthYearDateFormatter stringFromDate:date];
}

- (NSInteger)daysInMonthGrid {
    NSDate *startDate = [self.datesArray objectAtIndex:0];
    NSDate *endDate = [self.datesArray objectAtIndex:1];
    return [startDate daysBetweenDate:endDate] + 1;
}

- (void)adjustFrameForCollectionView:(UICollectionView *)collectionView withCell:(UICollectionViewCell *)collectionViewCell {
    int cellHeight = collectionViewCell.frame.size.height;
    int rowsInCollectionView = [self daysInMonthGrid] / 7;
    CGRect collectionViwFrame = collectionView.frame;
    collectionViwFrame.size.height = cellHeight * rowsInCollectionView;
    [collectionView setFrame:collectionViwFrame];
}

- (void)updateWeekdayTitles {
    NSMutableArray *weekDayTitles;
    for (UIView *headerSubView in self.monthGridHeader.subviews) {
        if (headerSubView != self.monthGridTitle || ![headerSubView isKindOfClass:[UIButton class]]) {
            [weekDayTitles addObject:headerSubView];
        }
    }
    
    CGFloat labelOffset = 320.0 / weekDayTitles.count;
    CGFloat currentOffset = 0.0;
    
    for (UILabel *weekdayTitle in weekDayTitles) {
        CGRect buttonFrame = [weekdayTitle frame];
        buttonFrame.origin.x = currentOffset;
        buttonFrame.size.width = labelOffset;
        [weekdayTitle setFrame:buttonFrame];
        
        currentOffset += labelOffset;
    }
}

-(void)reloadMonthGridForDate:(NSDate*) date{
    NSComparisonResult dateComparisionResult = [date compare:[self.datesArray objectAtIndex:0]];
    UIViewAnimationOptions animationOption = (dateComparisionResult == NSOrderedAscending) ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;

    [self prepareMonthGridForDate:date];
    [UIView transitionWithView:self.monthGridView duration:1.0 options:animationOption animations:^{
        UICollectionViewCell *collectionViewCell = [self.monthGridView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self adjustFrameForCollectionView:self.monthGridView withCell:collectionViewCell];
        [self.monthGridView reloadData];
    } completion:^(BOOL finished) {}];
}

- (void)recenterIfNecessary {
    CGPoint currentOffset = [self.monthGridView contentOffset];
    CGFloat contentWidth = [self.monthGridView.collectionViewLayout collectionViewContentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self.monthGridView bounds].size.width) / 2.0;
//    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
//    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.monthGridView.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
//        // move content by the same amount so it appears to stay still
//        for (UILabel *label in visibleLabels) {
//            CGPoint center = [labelContainerView convertPoint:label.center toView:self];
//            center.x += (centerOffsetX - currentOffset.x);
//            label.center = [self convertPoint:center toView:labelContainerView];
//        }
//    }
}



- (void) moveDataSourceDatesBy:(NSInteger)shift{
    for (int i=0; i<self.datesArray.count; i++) {
        NSDate* date = [self.datesArray objectAtIndex:i];
        date = [date dateByAddingDays:shift];
    }
}

#pragma mark - collectionview data source delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self daysInMonthGrid];
    }

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //    NSLog(@"requesting cell for indexPath.row = %d ", indexPath.row);
    UICalendarDateViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    TKDateInformation cellDateInfo = [[(NSDate *)[self.datesArray objectAtIndex:0] dateByAddingDays:indexPath.row] dateInformation];
    int dateNumber = cellDateInfo.day;
    cell.calendarDateLabel.text = [NSString stringWithFormat:@"%d", dateNumber];
    
    cell.calendarDateLabel.textColor = selectedDateInfo.month == cellDateInfo.month ? [UIColor monthGridTealColor] : [UIColor grayColor] ;
    
    if(indexPath.row == 0){
        [self adjustFrameForCollectionView:collectionView withCell:cell];
    }
    return cell;
}

#pragma  mark - UICollectionViewDelegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!isCollectionViewInWeekMode){
        isCollectionViewInWeekMode = YES;

        NSDate* userSelectedDate = [(NSDate *)[self.datesArray objectAtIndex:0] dateByAddingDays:indexPath.row];
        [self.weekInfiniteScrollView prepareScrollerWithDate:userSelectedDate];
        
        [UIView beginAnimations:@"showingWeekScroller" context:nil];
        [UIView setAnimationDuration:0.5];
        CGRect collectionViewFrame = collectionView.frame;
        collectionViewFrame.size.height = 0;
        
        self.weekInfiniteScrollView.hidden = NO;
        collectionView.frame = collectionViewFrame;
        [UIView commitAnimations];
    }
}


#pragma mark - target-action
- (IBAction)loadPreviousDates:(id)sender {
    [self reloadMonthGridForDate:[[self.datesArray objectAtIndex:0] dateByAddingDays:-1]];
}

- (IBAction)loadNextDates:(id)sender {
        [self reloadMonthGridForDate:[[self.datesArray lastObject] dateByAddingDays:1]];
}

#pragma mark - debug helper methods
-(void) printSize:(CGSize)viewSize{
    NSLog(@"width = %f", viewSize.width);
    NSLog(@"height = %f", viewSize.height);
    
}
@end
