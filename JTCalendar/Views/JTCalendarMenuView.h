//
//  JTCalendarMenuView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTMenu.h"

@interface JTCalendarMenuView : UIView<JTMenu, UIScrollViewDelegate>

@property (nonatomic, weak) JTCalendarManager *manager;

@property (nonatomic) CGFloat contentRatio;

@property (nonatomic, readonly) UIScrollView *scrollView;

/**
 Provides an external reference to the label container view that displays the
 second month's name when the calendar is able to show two months side by side
 (eg. on the iPad in landscape orientation)
 */
@property (nonatomic, readonly) UIView *secondMonthLabelView;

/*!
 * Must be call if override the class
 */
- (void)commonInit;

@end
