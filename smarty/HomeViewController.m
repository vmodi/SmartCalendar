//
//  HomeViewController.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "HomeViewController.h"
#import "UICalendarDateViewCell.h"
#import "DateHelper.h"
#import "UIColorExt.h";

@interface HomeViewController (){
	NSArray *marks;
    NSDateFormatter *monthYearDateFormatter;
    NSDate *selectedDate;
    TKDateInformation selectedDateInfo;
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
        // Custom initialization
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
    for (UIView *headerView in self.monthGridHeader.subviews) {
        if (headerView != self.monthGridTitle) {
            [weekDayTitles addObject:headerView];
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

#pragma mark - collectionview data source delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self daysInMonthGrid];
    }

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
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
    if(indexPath.row == 0 || indexPath.row == [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1){
        NSDate *firstOrLastDate = [(NSDate *)[self.datesArray objectAtIndex:0] dateByAddingDays:indexPath.row];
        [self prepareMonthGridForDate:firstOrLastDate];
        UIViewAnimationOptions animationOption = indexPath.row == 0 ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
        [UIView transitionWithView:collectionView duration:1.0 options:animationOption animations:^{
            UICollectionViewCell *collectionViewCell = [collectionView cellForItemAtIndexPath:indexPath];
            [self adjustFrameForCollectionView:collectionView withCell:collectionViewCell];
            [collectionView reloadData];
        } completion:^(BOOL finished) {}];
    }
}
@end
