//
//  LNNotificationAppSettings.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/18/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotificationAppSettings.h"

NSString *const LNAppAlertStyleKey = @"LNNotificationAlertStyleKey";
NSString *const LNNotificationsDisabledKey = @"LNNotificationsDisabledKey";
NSString *const LNAppSoundsKey = @"LNNotificationsSoundEnabledKey";
NSString *const LNAppNameKey = @"LNNotificationCenterAppNameKey";
NSString *const LNAppIconNameKey = @"LNNotificationCenterAppIconKey";

LNNotificationAppSettings *const LNNotificationDefaultAppSettings;

@implementation LNNotificationAppSettings

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNNotificationAppSettings* __strong* rv = (LNNotificationAppSettings**)&LNNotificationDefaultAppSettings;
		*rv = [LNNotificationAppSettings new];
		(*rv).alertStyle = LNNotificationAlertStyleBanner;
		(*rv).soundEnabled = YES;
	});
}

@end