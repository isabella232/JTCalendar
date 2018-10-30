//
//  JTCalendarScrollManager.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarScrollManager.h"

@implementation JTCalendarScrollManager

- (void)setMenuPreviousDate:(NSDate *)previousDate
                currentDate:(NSDate *)currentDate
                   nextDate:(NSDate *)nextDate
                  reuseDate:(NSDate *)reuseDate
{
    if(!_menuView){
        return;
    }
    
    [_menuView setPreviousDate:previousDate currentDate:currentDate nextDate:nextDate reuseDate:reuseDate];
}

- (void)setMenuPreviousDate:(NSDate *)previousDate
                currentDate:(NSDate *)currentDate
     currentSecondMonthDate:(NSDate * _Nullable)currentSecondMonthDate
                   nextDate:(NSDate *)nextDate
                  reuseDate:(NSDate *)reuseDate
{
    if(!_menuView){
        return;
    }
    
    [_menuView setPreviousDate:previousDate currentDate:currentDate currentSecondMonthDate:currentSecondMonthDate nextDate:nextDate reuseDate:reuseDate];
}

- (void)updateMenuContentOffset:(CGFloat)percentage pageMode:(NSUInteger)pageMode
{
    if(!_menuView){
        return;
    }
    
    [_menuView updatePageMode:pageMode];
    _menuView.scrollView.contentOffset = CGPointMake(percentage * _menuView.scrollView.contentSize.width, 0);
}

- (void)updateHorizontalContentOffset:(CGFloat)percentage
{
    if(!_horizontalContentView){
        return;
    }
    
    _horizontalContentView.contentOffset = CGPointMake(percentage * _horizontalContentView.contentSize.width, 0);
}

@end
