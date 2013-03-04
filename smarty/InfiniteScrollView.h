/*
     File: InfiniteScrollView.h
 */

#import <UIKit/UIKit.h>

@interface InfiniteScrollView : UIScrollView <UIScrollViewDelegate>

-(void) prepareScrollerWithDate:(NSDate *)date;
@end
