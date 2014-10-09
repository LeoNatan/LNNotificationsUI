//
//  LNNotificationCenter.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotificationCenter.h"
#import "LNNotification.h"
#import "LNNotificationAppSettings_Private.h"
#import "LNNotificationBannerWindow.h"

#import <AVFoundation/AVFoundation.h>

@interface LNNotificationAlertView : UIAlertView

@property (nonatomic, retain) LNNotification* alertBackingNotification;

@end

@implementation LNNotificationAlertView @end

@interface LNNotification ()

@property (nonatomic, copy) NSString* appIdentifier;

@end

static LNNotificationCenter* __ln_defaultNotificationCenter;

static NSString *const _LNSettingsKey = @"LNNotificationSettingsKey";

NSString* const LNNotificationWasTappedNotification = @"LNNotificationWasTappedNotification";;

@interface LNNotificationCenter () <UIAlertViewDelegate, AVAudioPlayerDelegate> @end

@implementation LNNotificationCenter
{
	NSMutableDictionary* _applicationMapping;
	NSMutableDictionary* _notificationSettings;
	LNNotificationBannerWindow* _notificationWindow;
	NSMutableArray* _pendingNotifications;
	
	LNNotificationBannerStyle _bannerStyle;
	BOOL _wantsBannerStyleChange;
	
	BOOL _currentlyAnimating;
	
	AVAudioPlayer* _currentAudioPlayer;
}

+ (instancetype)defaultCenter
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__ln_defaultNotificationCenter = [LNNotificationCenter new];
	});
	
	return __ln_defaultNotificationCenter;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_applicationMapping = [NSMutableDictionary new];
		_pendingNotifications = [NSMutableArray new];
		
		_notificationSettings = [[NSUserDefaults standardUserDefaults] valueForKey:_LNSettingsKey];
		if(_notificationSettings == nil)
		{
			_notificationSettings = [NSMutableDictionary new];
		}
	}
	
	return self;
}

- (LNNotificationBannerStyle)notificationsBannerStyle
{
	return _bannerStyle;
}

- (void)setNotificationsBannerStyle:(LNNotificationBannerStyle)bannerStyle
{
	_bannerStyle = bannerStyle;
	
	//Signal future handling of banner style change.
	_wantsBannerStyleChange = YES;
	
	if(_currentlyAnimating == NO)
	{
		//Handle banner change.
		[self _handleBannerCanChange];
	}
}

- (void)_handleBannerCanChange
{
	if(_wantsBannerStyleChange)
	{
		_notificationWindow.hidden = YES;
		_notificationWindow = nil;
		
		_wantsBannerStyleChange = NO;
	}
}

- (void)registerApplicationWithIdentifier:(NSString*)appIdentifier name:(NSString*)name icon:(UIImage*)icon defaultSettings:(LNNotificationAppSettings *)defaultSettings
{
	NSParameterAssert(appIdentifier != nil);
	NSParameterAssert(name != nil);
	NSParameterAssert(defaultSettings != nil);
	
	if(icon == nil)
	{
		icon = [UIImage imageNamed:@"LNNotificationsUIDefaultAppIcon"];
	}
	
	_applicationMapping[appIdentifier] = @{LNAppNameKey: name, LNAppIconNameKey: icon};
	if(_notificationSettings[appIdentifier] == nil)
	{
		[self _setSettings:defaultSettings enabled:YES forAppIdentifier:appIdentifier];
	}
}

- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifier;
{
	NSAssert(_applicationMapping[appIdentifier] != nil, @"Unrecognized app identifier: %@. The app must be registered with the notification center before attempting presentation of notifications for it.", appIdentifier);
	NSParameterAssert(notification.message != nil);
	
	if([_notificationSettings[appIdentifier][LNNotificationsDisabledKey] boolValue])
	{
		return;
	}

		if([_notificationSettings[appIdentifier][LNAppAlertStyleKey] unsignedIntegerValue] == LNNotificationAlertStyleNone)
		{
			[self _handleSoundForAppId:appIdentifier fileName:notification.soundName];
		}
		else
		{
			LNNotification* pendingNotification = [notification copy];
			
			pendingNotification.title = notification.title ? notification.title : _applicationMapping[appIdentifier][LNAppNameKey];
			pendingNotification.icon = notification.icon ? notification.icon : _applicationMapping[appIdentifier][LNAppIconNameKey];
			pendingNotification.alertAction = notification.alertAction ? notification.alertAction : NSLocalizedString(@"View", @"");
			pendingNotification.appIdentifier = appIdentifier;

			if([_notificationSettings[appIdentifier][LNAppAlertStyleKey] unsignedIntegerValue] == LNNotificationAlertStyleAlert)
			{
				LNNotificationAlertView* alert = [[LNNotificationAlertView alloc] initWithTitle:pendingNotification.title message:pendingNotification.message delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:pendingNotification.alertAction, nil];
				alert.alertBackingNotification = pendingNotification;
				[alert show];
				[self _handleSoundForAppId:appIdentifier fileName:notification.soundName];
			}
			else
			{
				[_pendingNotifications addObject:pendingNotification];
				
				[self _handlePendingNotifications];
			}
		}
}

- (void)_handlePendingNotifications
{
	if(_notificationWindow == nil)
	{
		_notificationWindow = [[LNNotificationBannerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds style:_bannerStyle];
		
		[_notificationWindow setHidden:NO];
	}
	
	if(_currentlyAnimating)
	{
		return;
	}
	
	_currentlyAnimating = YES;
	
	void(^block)() = ^ {
		_currentlyAnimating = NO;
		
		[self _handleBannerCanChange];
		
		[self _handlePendingNotifications];
	};
	
	if(_pendingNotifications.count == 0)
	{
		if(![_notificationWindow isNotificationViewShown])
		{
			_currentlyAnimating = NO;
			
			[self _handleBannerCanChange];
			
			return;
		}
		
		[_notificationWindow dismissNotificationViewWithCompletionBlock:block];
	}
	else
	{
		LNNotification* notification = _pendingNotifications.firstObject;
		[_pendingNotifications removeObjectAtIndex:0];
		
		[_notificationWindow presentNotification:notification completionBlock:block];
		
		[self _handleSoundForAppId:notification.appIdentifier fileName:notification.soundName];
	}
}

- (void)_handleSoundForAppId:(NSString*)appId fileName:(NSString*)fileName
{
	if(fileName == nil)
	{
		return;
	}
	
	if(![_notificationSettings[appId][LNAppSoundsKey] boolValue])
	{
		return;
	}
	
	NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
	NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
	
	[_currentAudioPlayer stop];
	
	_currentAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
	_currentAudioPlayer.delegate = self;
	[_currentAudioPlayer play];
}

- (NSDictionary*)_applicationsMapping
{
	return _applicationMapping;
}

- (NSDictionary*)_notificationSettings
{
	return _notificationSettings;
}

- (void)_setSettings:(LNNotificationAppSettings*)settings enabled:(BOOL)enabled forAppIdentifier:(NSString*)appIdentifier
{
	_notificationSettings[appIdentifier] = @{LNAppAlertStyleKey: @(settings.alertStyle), LNNotificationsDisabledKey: @(!enabled), LNAppSoundsKey: @(settings.soundEnabled)};
	
	[[NSUserDefaults standardUserDefaults] setObject:_notificationSettings forKey:_LNSettingsKey];
}

- (void)_setSettingsDictionary:(NSDictionary*)settings forAppIdentifier:(NSString*)appIdentifier
{
	_notificationSettings[appIdentifier] = [settings copy];
	
	[[NSUserDefaults standardUserDefaults] setObject:_notificationSettings forKey:_LNSettingsKey];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(LNNotificationAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView.cancelButtonIndex == buttonIndex)
	{
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:LNNotificationWasTappedNotification object:alertView.alertBackingNotification];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[_currentAudioPlayer stop];
	_currentAudioPlayer = nil;
}

@end
