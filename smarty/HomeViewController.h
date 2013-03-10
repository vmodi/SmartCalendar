//
//  HomeViewController.h
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteScrollView.h"


@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *monthGridView;
@property (strong, nonatomic) IBOutlet UIButton *monthGridTitle;


@property (strong, nonatomic) IBOutlet UIView *monthGridHeader;
@property (strong, nonatomic) IBOutlet InfiniteScrollView *weekInfiniteScrollView;
@property (strong, nonatomic) IBOutlet UIView *weekDaysContainer;
@property (strong, nonatomic) IBOutlet UIButton *monthRightArrow;
@property (strong, nonatomic) IBOutlet UIButton *monthLeftArrow;


- (IBAction)loadPreviousDates:(id)sender;
- (IBAction)loadNextDates:(id)sender;
- (IBAction)onMonthTitleClick:(id)sender;

@end
