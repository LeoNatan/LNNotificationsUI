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

static LNNotificationAppSettings* LNNotificationDefaultAppSettings;

@implementation LNNotificationAppSettings

+ (LNNotificationAppSettings*)defaultNotificationAppSettings
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LNNotificationDefaultAppSettings = [LNNotificationAppSettings new];
		LNNotificationDefaultAppSettings.alertStyle = LNNotificationAlertStyleBanner;
		LNNotificationDefaultAppSettings.soundEnabled = YES;
	});
	
	return LNNotificationDefaultAppSettings;
}

@end