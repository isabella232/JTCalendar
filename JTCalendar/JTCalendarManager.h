//
//  JTCalendarManager.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendarDelegate.h"

#import "JTContent.h"
#import "JTMenu.h"

#import "JTDateHelper.h"
#import "JTCalendarSettings.h"

#import "JTCalendarDelegateManager.h"
#import "JTCalendarScrollManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JTCalendarManager : NSObject

@property (nonatomic, weak) id<JTCalendarDelegate> _Nullable delegate;

@property (nonatomic, weak) UIView<JTMenu> * _Nullable menuView;
@property (nonatomic, weak) UIScrollView<JTContent> * _Nullable contentView;
@property (nonatomic, assign) BOOL showSecondMonth;

@property (nonatomic, readonly) JTDateHelper *dateHelper;
@property (nonatomic, readonly) JTCalendarSettings *settings;

// Intern methods

@property (nonatomic, readonly) JTCalendarDelegateManager *delegateManager;
@property (nonatomic, readonly) JTCalendarScrollManager *scrollManager;

// Use for override
- (void)commonInit;

- (NSDate *)date;
- (void)setDate:(NSDate *)date;
- (void)reload;

@end

NS_ASSUME_NONNULL_END
