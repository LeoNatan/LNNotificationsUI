//
//  LNNotification.h
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

@import UIKit;
@import Foundation;

@interface LNNotificationAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(LNNotificationAction* action))handler;

@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, copy, readonly) void (^handler)(LNNotificationAction* action);

@end

@interface LNNotification : NSObject <NSCopying>

+ (instancetype)notificationWithMessage:(NSString*)message;
+ (instancetype)notificationWithMessage:(NSString*)message title:(NSString*)title;
+ (instancetype)notificationWithMessage:(NSString*)message title:(NSString*)title icon:(UIImage*)icon date:(NSDate*)date;

- (instancetype)initWithMessage:(NSString*)message;
- (instancetype)initWithMessage:(NSString*)message title:(NSString*)title;
- (instancetype)initWithMessage:(NSString*)message title:(NSString*)title icon:(UIImage*)icon date:(NSDate*)date NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, strong) UIImage* icon;
@property (nonatomic, copy) NSDate* date;
@property (nonatomic) BOOL displaysWithRelativeDateFormatting;

@property (nonatomic, copy) NSString* soundName;

/**
 The default action attached to the notification.
 
 This action's handler is called when the user taps on the notification banned, and is the first button that appears when notifications are displayed as alerts.
 */
@property (nonatomic, strong) LNNotificationAction* defaultAction;
/**
 Additional actions attached to the notification.
 
 If the notification has multiple actions, the order in which they appear in the array determines their order in the resulting notification displayed.
 */
@property (nonatomic, copy) NSArray* otherActions;

@end
