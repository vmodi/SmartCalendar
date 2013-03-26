//
//  EventsFromKit.m
//  smarty
//
//

#import "EventsFromKit.h"

NSString *const EFKModelChangedNotification = @"EFKModelChangedNotification";
NSString *const EKEventStoreAccessGrantedNotification = @"EKEventStoreAccessGrantedNotification";

@implementation EventsFromKit{
    EKEventStore *eventStore;
    dispatch_queue_t fetchEventsQueue;
    Boolean broadcastChangedNotifications;
}

- (id)init {
    self = [super init];
    if (self) {
        eventStore = [[EKEventStore alloc] init];        
        if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            // iOS 6 and later
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted){
                    //---- codes here when user allow your app to access theirs' calendar.

                    self.selectedCalendar = eventStore.defaultCalendarForNewEvents;
                    
                    // Initialize a few internal data structures to store our events
                    self.events = [[NSArray alloc] init];
                    self.eventDates = [[NSArray alloc] init];
                    self.eventDateToEventsDictionary = [[NSDictionary alloc] init];
                    
                    // Use GCD so our UI doesn't block while we fetch events
                    fetchEventsQueue = dispatch_queue_create("fetchEventsQueue", DISPATCH_QUEUE_SERIAL);
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:EKEventStoreAccessGrantedNotification object:self];
                    });
                }else
                {
                    //----- codes here when user NOT allow your app to access the calendar.
                }
            }];
        }

    }
    return self;
}

- (enum SCEKAuthorizationStatus)requestCalendarAccessStatus{
    if([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)]){
        return [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    } else {
        return SCEKAuthorizationStatusAuthorized;
    }
}

- (void)startBroadcastingModelChangedNotifications {
    broadcastChangedNotifications = YES;
    
    // We want to listen to the EKEventStoreChangedNotification on the EKEventStore,
    // so that we update our list of events if anything changes in the EKEventStore (such as events added or removed).
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPokerEvents) name:EKEventStoreChangedNotification object:self.eventStore];
}

- (void)stopBroadcastingModelChangedNotifications {
    broadcastChangedNotifications = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)calendars {
    // Return all event supporting, writable calendars
    NSArray *allEventCalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *filteredCalendars = [NSMutableArray array];
    for (EKCalendar *calendar in allEventCalendars) {
        if (calendar.allowsContentModifications) {
            [filteredCalendars addObject:calendar];
        }
    }
    return filteredCalendars;
}

- (NSArray*)calendarTitles {
    NSArray *calendarTitles = [self.calendars valueForKey:@"title"];
    return [calendarTitles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (EKCalendar*)calendarWithTitle:(NSString*)title {
    for (EKCalendar *calendar in [self calendars]) {
        if ([calendar.title isEqualToString:title]) {
            return calendar;
        }
    }
    return nil;
}

- (void)fetchStoredEvents {
    // Dispatch using GCD so we don't block the UI while fetching events
    dispatch_async(fetchEventsQueue,^{
        
        // Create NSDates to represent our fetch date range
        // Range is arbitrary, yesterday to two months from now.
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
        oneDayAgoComponents.day = -1;
        NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                      toDate:[NSDate date]
                                                     options:0];
        
        NSDateComponents *twoMonthsInFutureComponents = [[NSDateComponents alloc] init];
        twoMonthsInFutureComponents.month = 2;
        NSDate *twoMonthsInFuture = [calendar dateByAddingComponents:twoMonthsInFutureComponents
                                                              toDate:[NSDate date]
                                                             options:0];
        
        // Create a predicate for our date range and the selected calendar
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:oneDayAgo
                                                                          endDate:twoMonthsInFuture
                                                                        calendars:@[self.selectedCalendar ]];
        NSArray *results = [eventStore eventsMatchingPredicate:predicate];
        
        // Filter the results by title
//        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title matches %@", defaultEventTitle];
//        results = [results filteredArrayUsingPredicate:titlePredicate];
        
        // Update our internal data structures
        [self updateDataStructuresWithMatchingEvents:results];
        
        // Notify our listeners (the UI) on the main thread that our model has changed
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EFKModelChangedNotification object:self];
        });
    });
}

// This should only be called from updateMatchingEvents: because that uses a serial queue
// which ensures only one thread is modifying our data structures.
- (void)updateDataStructuresWithMatchingEvents:(NSArray*)matchingEvents {
    // Sort the passed in events and then store them
    self.events = [matchingEvents sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    // Create an array of event start dates
    // Create a dictionary mapping from event start date to events with that start date
    NSMutableArray *eventDates = [NSMutableArray new];
    NSMutableDictionary *eventDictionary = [NSMutableDictionary new];
    
    for (EKEvent *event in self.events) {
        // Create an NSDate (startDate) that only has date components and no time components.
        NSDateComponents *dayMonthYearComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:event.startDate];
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:dayMonthYearComponents];
        
        // Get the array of events on a given start date from the dictionary
        NSMutableArray *eventsForStartDate = [eventDictionary objectForKey:startDate];
        
        // If the dictionary doesn't already have an array for this start date
        // then create one and also add the date to our array of dates
        if (eventsForStartDate == nil) {
            eventsForStartDate = [NSMutableArray array];
            [eventDates addObject:startDate];
            [eventDictionary setObject:eventsForStartDate forKey:startDate];
        }
        
        // Finally add the event to the dictionary
        [eventsForStartDate addObject:event];
    }
    
    self.eventDates = [eventDates copy];
    self.eventDateToEventsDictionary = [eventDictionary copy];
}


@end
