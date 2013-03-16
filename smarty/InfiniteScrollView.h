/*
     File: InfiniteScrollView.h
 */

#import <UIKit/UIKit.h>
#import "NSDate+TKCategory.h"

@protocol DateScrollerDelegate <NSObject>
-(void) monthChangedWithDateInfo:(NSDate*)dateInformation;
@end

@interface InfiniteScrollView : UIScrollView <UIScrollViewDelegate>

-(void) prepareScrollerWithDate:(NSDate *)date withDelegate:(id<DateScrollerDelegate>)delegate;
@end
