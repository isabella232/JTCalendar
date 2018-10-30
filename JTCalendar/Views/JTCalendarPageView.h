//
//  JTCalendarPageView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendarPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface JTCalendarPageView : UIView<JTCalendarPage>

@property (nonatomic, weak) JTCalendarManager * _Nullable manager;

@property (nonatomic) NSDate *date;

/*!
 * Must be call if override the class
 */
- (void)commonInit;

@end

NS_ASSUME_NONNULL_END
