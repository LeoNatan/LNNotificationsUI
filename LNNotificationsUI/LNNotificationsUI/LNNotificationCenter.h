//
//  LNNotificationCenter.h
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

@import UIKit;
@import Foundation;

@class LNNotification, LNNotificationAppSettings;

typedef NS_ENUM(NSUInteger, LNNotificationBannerStyle) {
	LNNotificationBannerStyleDark,
	LNNotificationBannerStyleLight
};

@interface LNNotificationCenter : NSObject

+ (instancetype)defaultCenter;

/**
 The notifications banner style. Default is dark.
 */
@property (nonatomic, assign) LNNotificationBannerStyle notificationsBannerStyle;

/**
 Registers an application with the notification center. Name and icon will be used for notification without titles and icons.

 Normally, should be called early in the application life cycle, before presenting notifications.
 */
- (void)registerApplicationWithIdentifier:(NSString*)appIdentifier name:(NSString*)name icon:(UIImage*)icon defaultSettings:(LNNotificationAppSettings*)defaultSettings;

/**
 Enqueues the specified notification for presentation when possible. The application identifier must be a previously registered identifier.
 */
- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifier;

/**
 Clears pending notifications for the specified application identifier.
 */
- (void)clearPendingNotificationsForApplicationIdentifier:(NSString*)appIdentifier;

/**
 Clears all pending notifications.
 */
- (void)clearAllPendingNotifications;

@end
