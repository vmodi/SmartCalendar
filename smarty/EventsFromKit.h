//
//  EventsFromKit.h
//  smarty
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

extern NSString *const EFKModelChangedNotification;

enum SCEKAuthorizationStatus {
    SCEKAuthorizationStatusNotDetermined = 0,
    SCEKAuthorizationStatusRestricted,
    SCEKAuthorizationStatusDenied,
    SCEKAuthorizationStatusAuthorized
};

@interface EventsFromKit : NSObject
@property (strong) EKCalendar *selectedCalendar;

// These are updated by fetchPokerEvents: to store the matching events
@property (strong) NSArray *events;
@property (strong) NSArray *eventDates;
@property (strong) NSDictionary *eventDateToEventsDictionary;

// Used for populating list of calendars
- (NSArray*)calendars;
- (NSArray*)calendarTitles;
- (EKCalendar*)calendarWithTitle:(NSString*)title;
- (void)startBroadcastingModelChangedNotifications;
- (void)stopBroadcastingModelChangedNotifications;

- (enum SCEKAuthorizationStatus)requestCalendarAccessStatus;

- (void)fetchStoredEvents;
@end
