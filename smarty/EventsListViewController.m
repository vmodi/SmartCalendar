//
//  EventsListViewController.m
//  smarty
//
//  Created by Vishal Modi on 4/6/13.
//  Copyright (c) 2013 vm. All rights reserved.
//

#import "EventsListViewController.h"
#import "EventsFromKit.h"
#import "DateHelper.h"

@interface EventsListViewController (){
    EventsFromKit *eventDataModel;
}
@end

@implementation EventsListViewController

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
    eventDataModel = [[EventsFromKit alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:EFKModelChangedNotification object:eventDataModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEvents) name:EKEventStoreAccessGrantedNotification object:eventDataModel];
    [eventDataModel startBroadcastingModelChangedNotifications];
    
    [self.infiniteDateScrollView prepareScrollerWithDate:[NSDate date] withDelegate:self];
    [self.eventsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"eventViewCell"];
;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return eventDataModel.eventDateToEventsDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray*)[eventDataModel.eventDateToEventsDictionary objectForKey:[eventDataModel.eventDates objectAtIndex:section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *eventCell = [tableView dequeueReusableCellWithIdentifier:@"eventViewCell"];

    
    NSArray* eventsForDateSection = ((NSArray*)[eventDataModel.eventDateToEventsDictionary objectForKey:[eventDataModel.eventDates objectAtIndex:indexPath.section]]);
    
    EKEvent *event = [eventsForDateSection objectAtIndex:indexPath.row];
    eventCell.textLabel.text = event.title;
    eventCell.detailTextLabel.text = event.startDate.description;
    
    return eventCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [DateHelper getDateInMonDdYyyy:[eventDataModel.eventDates objectAtIndex:section]];

}

#pragma mark - UITableViewDelegate methids
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    [self.infiniteDateScrollView setCurrentSelectedDate:[eventDataModel.eventDates objectAtIndex:(section + 1)]];
}


#pragma mark - DateScrollerDelegate methods
-(void) monthChangedWithDateInfo:(NSDate*)currentMonthDate{
}

#pragma mark - notification listener
-(void) getEvents{
    [eventDataModel fetchStoredEvents];
}

-(void) refreshView{
    [self.eventsTableView reloadData];
}
@end
