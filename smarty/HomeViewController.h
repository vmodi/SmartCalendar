//
//  HomeViewController.h
//  smarty
//
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *monthGridView;

@end
