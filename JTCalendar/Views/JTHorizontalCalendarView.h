//
//  JTHorizontalCalendar.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTContent.h"

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

/*!
 * Must be call if override the class
 */
- (void)commonInit;
- (CGSize)calendarPageSize;
- (BOOL)fullPageIsShowing;
- (NSArray *)displayedPages;

@end
