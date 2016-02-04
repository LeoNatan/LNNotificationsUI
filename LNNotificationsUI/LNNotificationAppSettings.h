//
//  LNNotificationAppSettings.h
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/18/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, LNNotificationAlertStyle) {
	/**
	 Do not display a visual alert.
	 */
	LNNotificationAlertStyleNone = 2,
	/**
	 Display a banner-style alert.
	 */
	LNNotificationAlertStyleBanner = 0,
	/**
	 Display an alert to the user.
	 */
	LNNotificationAlertStyleAlert = 1,
};

@interface LNNotificationAppSettings : NSObject

/**
 The alert style of the notification.
 */
@property (nonatomic) LNNotificationAlertStyle alertStyle;
@property (nonatomic) BOOL soundEnabled;

/**
 The default app settings for notifications.
 */
+ (LNNotificationAppSettings*)defaultNotificationAppSettings;

@end
