//
//  HomeViewController.m
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "HomeViewController.h"
#import "UICalendarDateViewCell.h"
#import "DateHelper.h"

@interface HomeViewController (){
    int firstOfPrev,lastOfPrev;
	NSArray *marks;
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
    
    self.datesArray = [DateHelper getMonthGridDatesForDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - public methods



#pragma - private methods
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

#pragma - collectionview data source delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self daysInMonthGrid];
    }

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICalendarDateViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    int dateNumber = [[(NSDate *)[self.datesArray objectAtIndex:0] dateByAddingDays:indexPath.row] dateInformation].day;
    cell.calendarDateLabel.text = [NSString stringWithFormat:@"%d", dateNumber];
    
    if(indexPath.row == 0){
        [self adjustFrameForCollectionView:collectionView withCell:cell];
    }
    return cell;
    }

#pragma  - UICollectionViewDelegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0 || indexPath.row == [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1){
        NSDate *selectedDate = [(NSDate *)[self.datesArray objectAtIndex:0] dateByAddingDays:indexPath.row];
        self.datesArray = [DateHelper getMonthGridDatesForDate:selectedDate];
        UIViewAnimationOptions animationOption = indexPath.row == 0 ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
        [UIView transitionWithView:collectionView duration:1.0 options:animationOption animations:^{
            UICollectionViewCell *collectionViewCell = [collectionView cellForItemAtIndexPath:indexPath];
            [self adjustFrameForCollectionView:collectionView withCell:collectionViewCell];
            [collectionView reloadData];
        } completion:^(BOOL finished) {}];
    }
}
@end
