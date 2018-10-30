//
//  JTCalendarPageView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarPageView.h"

#import "JTCalendarManager.h"

#define MAX_WEEKS_BY_MONTH 6

@implementation UIView (WJUtilities)

- (UIView *)addTrailingSeparatorOutsideView {
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    separatorView.backgroundColor = [UIColor redColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:separatorView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0/[UIScreen mainScreen].scale]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separatorView]|" options:0 metrics:nil views:@{@"separatorView":separatorView}]];
    return separatorView;
}

- (UIView *)addLeadingSeparatorOutsideView {
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    separatorView.backgroundColor = [UIColor redColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:separatorView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0/[UIScreen mainScreen].scale]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separatorView]|" options:0 metrics:nil views:@{@"separatorView":separatorView}]];
    return separatorView;
}

@end

@interface JTCalendarPageView (){
    UIView<JTCalendarWeekDay> *_weekDayView;
    NSMutableArray *_weeksViews;
    NSUInteger _numberOfWeeksDisplayed;
    UIView *_trailingSeparatorOutsideView;
    UIView *_leadingSeparatorOutsideView;
}

@end

@implementation JTCalendarPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    _trailingSeparatorOutsideView = [self addTrailingSeparatorOutsideView];
    _leadingSeparatorOutsideView = [self addLeadingSeparatorOutsideView];
    _date = [NSDate date]; // ensure date is never nil
}

- (void)setDate:(NSDate *)date
{
    NSAssert(_manager != nil, @"manager cannot be nil");
    NSAssert(date != nil, @"date cannot be nil");
    
    self->_date = date;
    
    [self reload];
}

- (void)reload
{
    if(_manager.settings.pageViewHaveWeekDaysView && !_weekDayView){
        _weekDayView = [_manager.delegateManager buildWeekDayView];
        [self addSubview:_weekDayView];
        
        _weekDayView.manager = _manager;
        [_weekDayView reload];
    }
    
    if(!_weeksViews){
        _weeksViews = [NSMutableArray new];
        
        for(int i = 0; i < MAX_WEEKS_BY_MONTH; ++i){
            UIView<JTCalendarWeek> *weekView = [_manager.delegateManager buildWeekView];
            [_weeksViews addObject:weekView];
            [self addSubview:weekView];
                        
            weekView.manager = _manager;
        }
    }
    
    NSDate *weekDate = nil;
    
    if(_manager.settings.weekModeEnabled){
        _numberOfWeeksDisplayed = MIN(MAX(_manager.settings.pageViewWeekModeNumberOfWeeks, 1), MAX_WEEKS_BY_MONTH);
        weekDate = [_manager.dateHelper firstWeekDayOfWeek:_date];
    }
    else{
        _numberOfWeeksDisplayed = MIN(_manager.settings.pageViewNumberOfWeeks, MAX_WEEKS_BY_MONTH);
        if(_numberOfWeeksDisplayed == 0){
            _numberOfWeeksDisplayed = [_manager.dateHelper numberOfWeeks:_date];
        }
        
        weekDate = [_manager.dateHelper firstWeekDayOfMonth:_date];
    }
    
    for(NSUInteger i = 0; i < _numberOfWeeksDisplayed; i++){
        UIView<JTCalendarWeek> *weekView = _weeksViews[i];
        
        weekView.hidden = NO;
        
        // Process the check on another month for the 1st, 4th and 5th weeks
        if(i == 0 || i >= 4){
            [weekView setStartDate:weekDate updateAnotherMonth:YES monthDate:_date];
        }
        else{
            [weekView setStartDate:weekDate updateAnotherMonth:NO monthDate:_date];
        }
        
        weekDate = [_manager.dateHelper addToDate:weekDate weeks:1];
    }
    
    for(NSUInteger i = _numberOfWeeksDisplayed; i < MAX_WEEKS_BY_MONTH; i++){
        UIView<JTCalendarWeek> *weekView = _weeksViews[i];
        
        weekView.hidden = YES;
    }
}

- (void)updateForPagePosition:(JTCalendarPagePosition)pagePosition {
    
    switch (pagePosition) {
        case JTCalendarPagePositionLeftOffscreen: {
            _trailingSeparatorOutsideView.hidden = YES;
            _leadingSeparatorOutsideView.hidden = YES;
            break;
        }
        case JTCalendarPagePositionLeftVisible: {
            _trailingSeparatorOutsideView.hidden = NO;
            _leadingSeparatorOutsideView.hidden = NO;
            break;
        }
        case JTCalendarPagePositionRightVisible: { // iPad only
            _trailingSeparatorOutsideView.hidden = NO;
            _leadingSeparatorOutsideView.hidden = YES;
            break;
        }
        case JTCalendarPagePositionRightOffscreen: {
            _trailingSeparatorOutsideView.hidden = YES;
            _leadingSeparatorOutsideView.hidden = YES;
            break;
        }
        case JTCalendarPagePositionReuse: {
            _trailingSeparatorOutsideView.hidden = YES;
            _leadingSeparatorOutsideView.hidden = YES;
            break;
        }
    }
}

- (void)layoutSubviews
{    
    if(!_weeksViews){
        return;
    }
    
    CGFloat y = 0;
    CGFloat weekWidth = self.frame.size.width;
    
    if(_manager.settings.pageViewHaveWeekDaysView){
        CGFloat weekDayHeight = _weekDayView.frame.size.height; // Force use default height
        
        if(weekDayHeight == 0){ // Or use the same height than weeksViews
            weekDayHeight = self.frame.size.height / (_numberOfWeeksDisplayed + 1);
        }
        
        _weekDayView.frame = CGRectMake(0, 0, weekWidth, weekDayHeight);
        y = weekDayHeight;
    }
    
    CGFloat weekHeight = (self.frame.size.height - y) / _numberOfWeeksDisplayed;
    
    for(UIView *weekView in _weeksViews){
        weekView.frame = CGRectMake(0, y, weekWidth, weekHeight);
        y += weekHeight;
    }
}

@end
