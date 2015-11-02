//
//  JTCalendarMenuView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMenuView.h"

#import "JTCalendarManager.h"

typedef NS_ENUM(NSInteger, JTCalendarPageMode) {
    JTCalendarPageModeFull,
    JTCalendarPageModeCenter,
    JTCalendarPageModeCenterLeft,
    JTCalendarPageModeCenterRight
};

@interface JTCalendarMenuView (){
    CGSize _lastSize;
    
    UIView *_leftView;
    UIView *_centerView;
    UIView *_centerSecondMonthView;
    UIView *_rightView;
    UIView *_reuseView;
    
    JTCalendarPageMode _pageMode;
}

@end

@implementation JTCalendarMenuView

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
    self.clipsToBounds = YES;
    
    _contentRatio = 1.;
    
    {
        _scrollView = [UIScrollView new];
        [self addSubview:_scrollView];
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.delegate = self;
        
        _scrollView.clipsToBounds = NO;
    }
}

- (void)layoutSubviews
{
    [self resizeViewsIfWidthChanged];
}

- (CGSize)menuSize {
    CGSize size = self.frame.size;
    
    if (self.manager.showSecondMonth) {
        size.width /= 2;
    }
    
    return size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_scrollView.contentSize.width <= 0){
        return;
    }

    [_manager.scrollManager updateHorizontalContentOffset:(_scrollView.contentOffset.x / _scrollView.contentSize.width)];
}

- (void)resizeViewsIfWidthChanged
{
    CGSize size = [self menuSize];
    if(size.width != _lastSize.width){
        _lastSize = size;
        
        [self repositionViews];
    }
    else if(size.height != _lastSize.height){
        _lastSize = size;
        
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, size.height);
        
        _leftView.frame = CGRectMake(_leftView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        _centerView.frame = CGRectMake(_centerView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        _rightView.frame = CGRectMake(_rightView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        _reuseView.frame = CGRectMake(_reuseView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        
        if (self.manager.showSecondMonth) {
            _centerSecondMonthView.frame = CGRectMake(_centerView.frame.origin.x, 0, _scrollView.frame.size.width, size.height);
        }
    }
}

- (void)repositionViews
{
    // Avoid vertical scrolling when the view is in a UINavigationController
    _scrollView.contentInset = UIEdgeInsetsZero;
    
    {
        CGFloat width = [self menuSize].width * _contentRatio;
        CGFloat x = ([self menuSize].width - width);
        CGFloat height = [self menuSize].height;
        
        _scrollView.frame = CGRectMake(x, 0, width, height);
        _scrollView.contentSize = CGSizeMake(width, height);
    }
    
    CGSize size = _scrollView.frame.size;
    
    switch (_pageMode) {
        case JTCalendarPageModeFull: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 4 : 3;
            _scrollView.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateViewFramesWithStartIndex:0];
            break;
        }
        case JTCalendarPageModeCenter:
            _scrollView.contentSize = size;
            [self updateViewFramesWithStartIndex:-1];
            break;
        case JTCalendarPageModeCenterLeft: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            _scrollView.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateViewFramesWithStartIndex:0];
            break;
        }
        case JTCalendarPageModeCenterRight: {
            NSInteger numberOfPages = self.manager.showSecondMonth ? 3 : 2;
            _scrollView.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
            [self updateViewFramesWithStartIndex:-1];
            break;
        }
    }
}

- (void)updateViewFramesWithStartIndex:(NSInteger)startIndex {
    CGSize size = _scrollView.frame.size;
    NSInteger viewCount = startIndex;
    _leftView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    _centerView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    if (self.manager.showSecondMonth) {
        _centerSecondMonthView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    }
    _rightView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    _reuseView.frame = CGRectMake(size.width * viewCount++, 0, size.width, size.height);
    _scrollView.contentOffset = CGPointMake((1 + startIndex) * size.width, 0);
}

- (void)setPreviousDate:(NSDate *)previousDate
            currentDate:(NSDate *)currentDate
               nextDate:(NSDate *)nextDate
              reuseDate:(NSDate *)reuseDate
{
    [self setPreviousDate:previousDate currentDate:currentDate currentSecondMonthDate:nil nextDate:nextDate reuseDate:reuseDate];
}

- (void)setPreviousDate:(NSDate *)previousDate
            currentDate:(NSDate *)currentDate
 currentSecondMonthDate:(NSDate *)currentSecondMonthDate
               nextDate:(NSDate *)nextDate
              reuseDate:(NSDate *)reuseDate
{
    NSAssert(currentDate != nil, @"currentDate cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    if(!_leftView){
        _leftView = [_manager.delegateManager buildMenuItemView];
        [_scrollView addSubview:_leftView];
        
        _centerView = [_manager.delegateManager buildMenuItemView];
        [_scrollView addSubview:_centerView];
        
        if (self.manager.showSecondMonth) {
            _centerSecondMonthView = [_manager.delegateManager buildMenuItemView];
            [_scrollView addSubview:_centerSecondMonthView];
        }
        
        _rightView = [_manager.delegateManager buildMenuItemView];
        [_scrollView addSubview:_rightView];
        
        _reuseView = [_manager.delegateManager buildMenuItemView];
        [_scrollView addSubview:_reuseView];
    }
    
    [_manager.delegateManager prepareMenuItemView:_leftView date:previousDate];
    [_manager.delegateManager prepareMenuItemView:_centerView date:currentDate];
    [_manager.delegateManager prepareMenuItemView:_rightView date:nextDate];
    [_manager.delegateManager prepareMenuItemView:_reuseView date:reuseDate];
    
    if (self.manager.showSecondMonth) {
        [_manager.delegateManager prepareMenuItemView:_centerSecondMonthView date:currentSecondMonthDate];
    }
    
    BOOL haveLeftPage = [_manager.delegateManager canDisplayPageWithDate:previousDate];
    BOOL haveRightPage = [_manager.delegateManager canDisplayPageWithDate:nextDate];
        
    if(_manager.settings.pageViewHideWhenPossible){
        _leftView.hidden = !haveLeftPage;
        _rightView.hidden = !haveRightPage;
    }
    else{
        _leftView.hidden = NO;
        _rightView.hidden = NO;
    }
}

- (void)updatePageMode:(NSUInteger)pageMode
{
    if(_pageMode == pageMode){
        return;
    }
    
    _pageMode = pageMode;
    [self repositionViews];
}

@end
