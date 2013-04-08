//
//  EventsListViewController.h
//  smarty
//
//  Created by Vishal Modi on 4/6/13.
//  Copyright (c) 2013 vm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteScrollView.h"

@interface EventsListViewController : UIViewController <DateScrollerDelegate>
@property (strong, nonatomic) IBOutlet InfiniteScrollView *infiniteDateScrollView;

@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@end
