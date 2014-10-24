//
//  LNNotificationBannerView.h
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/5/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LNNotificationCenter.h"

@class LNNotification;

@interface LNNotificationBannerView : UIView

@property (nonatomic, strong, readonly) UIView* backgroundView;
@property (nonatomic, strong, readonly) UIView* notificationContentView;

- (instancetype)initWithFrame:(CGRect)frame style:(LNNotificationBannerStyle)style;

- (void)configureForNotification:(LNNotification*)notification;

@property (nonatomic, strong, readonly) LNNotification* currentNotification;

@end
