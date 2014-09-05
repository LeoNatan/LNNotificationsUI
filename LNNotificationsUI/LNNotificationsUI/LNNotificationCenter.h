//
//  LNNotificationCenter.h
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class LNNotification;

extern NSString* const LNNotificationWasTappedNotification;

@interface LNNotificationCenter : NSObject

+ (instancetype)defaultCenter;

/**
 Registers an application with the notification center. Name and icon will be used for notification without titles and icons.

 Normally, should be called early in the application life cycle, before presenting notifications.
 */
- (void)registerApplicationWithIdentifier:(NSString*)appIdentifer name:(NSString*)name icon:(UIImage*)icon;

/**
 Enqueues the specified notification for presentation when possible. The application identifier must be a previously registered identifier.
 */
- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifer;

@end
