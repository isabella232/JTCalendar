//
//  JTHorizontalCalendar.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTContent.h"
#import "JTCalendarPage.h"

typedef NS_ENUM(NSInteger, JTCalendarPageMode) {
    JTCalendarPageModeFull,
    JTCalendarPageModeCenter,
    JTCalendarPageModeCenterLeft,
    JTCalendarPageModeCenterRight
};

@interface JTHorizontalCalendarView : UIScrollView<JTContent, UIScrollViewDelegate>

@property (nonatomic, weak) JTCalendarManager *manager;
@property (assign, nonatomic) JTCalendarPageMode pageMode;

@property (nonatomic) NSDate *date;

/**
 Provides an external reference to the month container view that displays the
 second month when the calendar is able to show two months side by side
 (eg. on the iPad in landscape orientation)
 */
@property (nonatomic, readonly) UIView<JTCalendarPage> *centerSecondMonthView;

/*!
 * Must be call if override the class
 */
- (void)commonInit;
- (CGSize)calendarPageSize;
- (BOOL)fullPageIsShowing;
- (NSArray *)displayedPages;

@end
