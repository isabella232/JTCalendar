//
//  JTCalendarPage.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <Foundation/Foundation.h>

@class JTCalendarManager;

typedef NS_ENUM(NSInteger, JTCalendarPagePosition) {
    JTCalendarPagePositionLeftOffscreen,
    JTCalendarPagePositionLeftVisible,
    JTCalendarPagePositionRightVisible, // iPad only
    JTCalendarPagePositionRightOffscreen,
    JTCalendarPagePositionReuse
};

NS_ASSUME_NONNULL_BEGIN

@protocol JTCalendarPage <NSObject>

- (void)setManager:(JTCalendarManager *)manager;

- (NSDate *)date;
- (void)setDate:(NSDate *)date;

- (void)reload;
- (void)updateForPagePosition:(JTCalendarPagePosition)pagePosition;

@end

NS_ASSUME_NONNULL_END
