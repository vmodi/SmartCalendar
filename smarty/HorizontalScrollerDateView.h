//
//  HorizontalScrollerDateView.h
//  smarty
//
//  Created by Vishal Modi on 3/2/13.
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalScrollerDateView : UIView
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (readonly, copy) NSDate* cellDate;
@property (atomic) BOOL isActive;

-(void) populateCellWithDate:(NSDate*)date;
@end
