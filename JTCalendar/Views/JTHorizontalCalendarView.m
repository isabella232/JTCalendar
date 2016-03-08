//
//  JTHorizontalCalendar.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTHorizontalCalendarView.h"

#import "JTCalendarManager.h"

@interface JTHorizontalCalendarView (){
    CGSize _lastSize;
    
    UIView<JTCalendarPage> *_leftView;
    UIView<JTCalendarPage> *_centerView;
    UIView<JTCalendarPage> *_centerSecondMonthView; //for use with two month view
    UIView<JTCalendarPage> *_rightView;
    UIView<JTCalendarPage> *_reuseView;
}

@end

@implementation JTHorizontalCalendarView

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
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceHorizontal = YES;
    self.clipsToBounds = YES;
    self.delegate = self;
}

- (void)layoutSubviews
{
    [self resizeViewsIfWidthChanged];
    [self viewDidScroll];
}

- (void)resizeViewsIfWidthChanged
{
    CGSize size = [self calendarPageSize];
    if(size.width != _lastSize.width){
        _lastSize = size;
        
        [self repositionViews];
    }
    else if(size.height != _lastSize.height){
        _lastSize = size;
        
        _leftView.frame = CGRectMake(_leftView.frame.origin.x, 0, size.width, size.height);
        _centerView.frame = CGRectMake(_centerView.frame.origin.x, 0, size.width, size.height);
        _rightView.frame = CGRectMake(_rightView.frame.origin.x, 0, size.width, size.height);
        _reuseView.frame = CGRectMake(_rightView.frame.origin.x, 0, size.width, size.height);
        
        if (self.manager.showSecondMonth) {
            _centerSecondMonthView.frame = CGRectMake(_centerSecondMonthView.frame.origin.x, 0, size.width, size.height);
        }
        
        self.contentSize = CGSizeMake(self.contentSize.width, size.height);
    }
}

- (void)viewDidScroll
{
    if(self.contentSize.width <= 0){
        return;
    }

    CGSize size = [self calendarPageSize];
    
    switch (self.pageMode) {
        case JTCalendarPageModeFull:
            
            if(self.contentOffset.x <= 0){
                [self loadPreviousPage];
            }
            else if(self.contentOffset.x >= size.width * 2){
                [self loadNextPage];
            }
            
            break;
        case JTCalendarPageModeCenter:
            
            break;
        case JTCalendarPageModeCenterLeft:
            
            if(self.contentOffset.x <= 0){
                [self loadPreviousPage];
            }
            
            break;
        case JTCalendarPageModeCenterRight:
            
            if(self.contentOffset.x >= size.width){
                [self loadNextPage];
            }
            
            break;
    }
    
    [_manager.scrollManager updateMenuContentOffset:(self.contentOffset.x / self.contentSize.width) pageMode:self.pageMode];
}

- (BOOL)fullPageIsShowing {
    CGSize size = [self calendarPageSize];
    CGFloat proportionScrolled = fmod(self.contentOffset.x, size.width) / size.width;
    return proportionScrolled == 0;
}

- (void)loadPreviousPageWithAnimation
{
    switch (self.pageMode) {
        case JTCalendarPageModeCenterRight:
        case JTCalendarPageModeCenter:
            return;
        default:
            break;
    }
    
    CGSize size = [self calendarPageSize];
    CGPoint point = CGPointMake(self.contentOffset.x - size.width, 0);
    [self setContentOffset:point animated:YES];
}

- (void)loadNextPageWithAnimation
{
    switch (self.pageMode) {
        case JTCalendarPageModeCenterLeft:
        case JTCalendarPageModeCenter:
            return;
        default:
            break;
    }
    
    CGSize size = [self calendarPageSize];
    CGPoint point = CGPointMake(self.contentOffset.x + size.width, 0);
    [self setContentOffset:point animated:YES];
}

- (CGSize)calendarPageSize {
    CGSize size = self.frame.size;
    
    if (self.manager.showSecondMonth) {
        size.width /= 2;
    }
    
    return size;
}

// should *just* be moving and updating the reuseView
- (void)loadPreviousPage
{
    
    // Must be set before chaging date for PageView for updating day views
    self->_date = _leftView.date;
    
    // cycle all the views
    UIView<JTCalendarPage> *tmpView = _rightView; // right view is disappearing
    
    if (self.manager.showSecondMonth) {
        _rightView = _centerSecondMonthView;
        _centerSecondMonthView = _centerView;
    } else {
        _rightView = _centerView;
    }
    
    _centerView = _leftView;
    _leftView = _reuseView; // will be the *next* left view
    _reuseView = tmpView;

    _leftView.date = [_manager.delegateManager dateForPreviousPageWithCurrentDate:_centerView.date];
    
    [self updateMenuDates];
    
    JTCalendarPageMode previousPageMode = self.pageMode;
    
    [self updatePageMode];
    
    CGSize size = [self calendarPageSize];
    
    switch (self.pageMode) {
        case JTCalendarPageModeFull: {
            NSInteger viewCount = 0;
            NSInteger numberOfPages = self.manager.showSecondMonth ? 4 : 3;
            
            if(previousPageMode == JTCalendarPageModeFull || previousPageMode ==  JTCalendarPageModeCenterLeft){
                _leftView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                _centerView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                if (self.manager.showSecondMonth) {
                    _centerSecondMonthView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                }
                _rightView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                _reuseView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                self.contentOffset = CGPointMake(size.width, 0);
            }
            
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            
            break;
        }
        case JTCalendarPageModeCenter:
            // Not tested
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            
            self.contentSize = size;
            
            break;
        case JTCalendarPageModeCenterLeft: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            
            _leftView.frame = CGRectMake(0, 0, size.width, size.height);
            
            self.contentOffset = CGPointMake(self.contentOffset.x + size.width, 0);
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            
            break;
        }
        case JTCalendarPageModeCenterRight: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            
            _leftView.frame = CGRectMake(- size.width, 0, size.width, size.height);
            
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            
            break;
        }
    }
    
    // Update the dayView that wasn't already correct
    [_leftView reload];
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarDidLoadPreviousPage:)]){
        [_manager.delegate calendarDidLoadPreviousPage:_manager];
    }
}

// should *just* be moving and updating the reuseView
- (void)loadNextPage
{
    
    // Must be set before chaging date for PageView for updating day views
    self->_date = _rightView.date;

    // cycle all the views
    UIView<JTCalendarPage> *tmpView = _leftView; // left view is disappearing
    _leftView = _centerView;
    
    if (self.manager.showSecondMonth) {
        _centerView = _centerSecondMonthView;
        _centerSecondMonthView = _rightView;
    } else {
        _centerView = _rightView;
    }
    
    _rightView = _reuseView; // will be the *next* right view
    _reuseView = tmpView;
    
    _reuseView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:_rightView.date];
    
    [self updateMenuDates];
    
    JTCalendarPageMode previousPageMode = self.pageMode;
    
    [self updatePageMode];
    
    CGSize size = [self calendarPageSize];
    
    switch (self.pageMode) {
        case JTCalendarPageModeFull: {
            NSInteger viewCount = 0;
            NSInteger numberOfPages = self.manager.showSecondMonth ? 4 : 3;
            
            if(previousPageMode == JTCalendarPageModeFull){
                _leftView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                _centerView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                if (self.manager.showSecondMonth) {
                    _centerSecondMonthView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                }
                _rightView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
                _reuseView.frame = CGRectMake(size.width * numberOfPages, 0, size.width, size.height);
                
                self.contentOffset = CGPointMake(size.width, 0);
            }
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            
            break;
        }
        case JTCalendarPageModeCenter: {
            // Not tested
            NSInteger numberOfPages = self.manager.showSecondMonth ? 4 : 3;
            _reuseView.frame = CGRectMake(size.width * numberOfPages, 0, size.width, size.height);
            self.contentSize = size;
            
            break;
        }
        case JTCalendarPageModeCenterLeft: {
            NSInteger viewCount = 0;
            
            _leftView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
            _centerView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
            if (self.manager.showSecondMonth) {
                _centerSecondMonthView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
            }
            _rightView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);

             _reuseView.frame = CGRectMake(-size.width, 0, size.width, size.height);
            if(previousPageMode != JTCalendarPageModeCenterLeft){
                self.contentOffset = CGPointMake(size.width, 0);
            }

            // Must be set a the end else the scroll freeze
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);

            break;
        }
        case JTCalendarPageModeCenterRight: {
            // Not tested
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            _reuseView.frame = CGRectMake(size.width * numberOfPages, 0, size.width, size.height);
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            
            break;
        }
    }
    
    // Update the dayView that wasn't already correct
    [_rightView reload];
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarDidLoadNextPage:)]){
        [_manager.delegate calendarDidLoadNextPage:_manager];
    }
}

- (void)setDate:(NSDate *)date
{
    NSAssert(date != nil, @"date cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    if (self.manager.showSecondMonth && ![self.manager.delegateManager canDisplayPageWithDate:[self.manager.dateHelper addToDate:date months:1]]) {
        date = [self.manager.dateHelper addToDate:date months:-1];
    }
    
    self->_date = date;
    
    if(!_leftView){
        _leftView = [_manager.delegateManager buildPageView];
        [self addSubview:_leftView];
        
        _centerView = [_manager.delegateManager buildPageView];
        [self addSubview:_centerView];
        
        if (self.manager.showSecondMonth) {
            _centerSecondMonthView = [_manager.delegateManager buildPageView];
            [self addSubview:_centerSecondMonthView];
        }
        
        _rightView = [_manager.delegateManager buildPageView];
        [self addSubview:_rightView];
        
        _reuseView = [_manager.delegateManager buildPageView];
        [self addSubview:_reuseView];

        [self updateManagerForViews];
    }
    
    _leftView.date = [_manager.delegateManager dateForPreviousPageWithCurrentDate:date];
    _centerView.date = date;
    if (self.manager.showSecondMonth) {
        _centerSecondMonthView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:date];
        _rightView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:_centerSecondMonthView.date];
    } else {
        _rightView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:date];
    }
    _reuseView.date = [_manager.delegateManager dateForNextPageWithCurrentDate:_rightView.date]; // assumes will generally scroll to the right view first
    
    [self updateMenuDates];
    
    [self updatePageMode];
    [self repositionViews];
}

- (void)setManager:(JTCalendarManager *)manager
{
    self->_manager = manager;
    [self updateManagerForViews];
}

- (void)updateManagerForViews
{
    if(!_manager || !_leftView){
        return;
    }
    
    _leftView.manager = _manager;
    _centerView.manager = _manager;
    _rightView.manager = _manager;
    _reuseView.manager = _manager;
    
    if (self.manager.showSecondMonth) {
        _centerSecondMonthView.manager = _manager;
    }
}

- (void)updatePageMode
{
    BOOL haveLeftPage = [_manager.delegateManager canDisplayPageWithDate:_leftView.date];
    BOOL haveRightPage = [_manager.delegateManager canDisplayPageWithDate:_rightView.date];
    
    if(haveLeftPage && haveRightPage){
        self.pageMode = JTCalendarPageModeFull;
    }
    else if(!haveLeftPage && !haveRightPage){
        self.pageMode = JTCalendarPageModeCenter;
    }
    else if(!haveLeftPage){
        self.pageMode = JTCalendarPageModeCenterRight;
    }
    else{
        self.pageMode = JTCalendarPageModeCenterLeft;
    }
    
    if(_manager.settings.pageViewHideWhenPossible){
        _leftView.hidden = !haveLeftPage;
        _rightView.hidden = !haveRightPage;
    }
    else{
        _leftView.hidden = NO;
        _rightView.hidden = NO;
    }
}

- (void)repositionViews
{
    CGSize size = [self calendarPageSize];
    self.contentInset = UIEdgeInsetsZero;
    
    switch (self.pageMode) {
        case JTCalendarPageModeFull: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 4 : 3;
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateCalendarPageFrameForStartIndex:0];
            break;
        }
        case JTCalendarPageModeCenter: {
            self.contentSize = size;
            [self updateCalendarPageFrameForStartIndex:-1];
            break;
        }
        case JTCalendarPageModeCenterLeft: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateCalendarPageFrameForStartIndex:0];
            break;
        }
        case JTCalendarPageModeCenterRight: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            self.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateCalendarPageFrameForStartIndex:-1];
            break;
        }
    }
}

- (void)updateCalendarPageFrameForStartIndex:(NSInteger)startIndex {
    CGSize size = [self calendarPageSize];
    NSInteger viewCount = startIndex;
    _leftView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    _centerView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    if (self.manager.showSecondMonth) {
        _centerSecondMonthView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    }
    _rightView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    _reuseView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    self.contentOffset = CGPointMake((1 + startIndex) * size.width, 0);
}

- (void)updateMenuDates
{
    if (self.manager.showSecondMonth) {
        [_manager.scrollManager setMenuPreviousDate:_leftView.date
                                        currentDate:_centerView.date
                             currentSecondMonthDate:_centerSecondMonthView.date
                                           nextDate:_rightView.date
                                          reuseDate:_reuseView.date];
    } else {
        [_manager.scrollManager setMenuPreviousDate:_leftView.date
                                        currentDate:_centerView.date
                                           nextDate:_rightView.date
                                          reuseDate:_reuseView.date];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setContentOffsetForCalendarPaging];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self setContentOffsetForCalendarPaging];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if(_manager.delegate && [_manager.delegate respondsToSelector:@selector(calendarDidEndScrollingAnimation:)]){
        [_manager.delegate calendarDidEndScrollingAnimation:scrollView];
    }
}

- (void)setContentOffsetForCalendarPaging {
    CGSize pageSize = [self calendarPageSize];
    NSInteger pageChange = 0;
    CGFloat pageSwitchThreshold = 0.1;
    
    switch (self.pageMode) {
        case JTCalendarPageModeCenterRight:
            if (self.contentOffset.x > pageSize.width * pageSwitchThreshold) {
                pageChange = 1;
            } else if (self.contentOffset.x < -pageSize.width * pageSwitchThreshold) {
                pageChange = 0;
            }
            break;
        case JTCalendarPageModeFull:
            if (self.contentOffset.x > pageSize.width * (1 + pageSwitchThreshold)) {
                pageChange = 2;
            } else if (self.contentOffset.x < pageSize.width * (1 - pageSwitchThreshold)) {
                pageChange = 0;
            } else {
                pageChange = 1;
            }
            break;
        case JTCalendarPageModeCenterLeft:
            if (self.contentOffset.x < pageSize.width *  (1 - pageSwitchThreshold)) {
                pageChange = 0;
            } else {
                pageChange = 1;
            }
            break;
        default:
            break;
    }
    
    [self setContentOffset:CGPointMake(pageChange * pageSize.width, 0) animated:YES];
}

@end
