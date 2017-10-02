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

@interface LNNotificationAlertView : UIAlertView <UIAlertViewDelegate>

@property (nonatomic, retain) LNNotification* alertBackingNotification;

@end

@implementation LNNotificationAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == alertView.cancelButtonIndex)
	{
		return;
	}
	
	if(buttonIndex == alertView.cancelButtonIndex + 1 && self.alertBackingNotification.defaultAction.handler)
	{
		self.alertBackingNotification.defaultAction.handler(self.alertBackingNotification.defaultAction);
	}
	
	if(buttonIndex > alertView.cancelButtonIndex + 1 && [self.alertBackingNotification.otherActions[buttonIndex - 2] handler] != nil)
	{
		LNNotificationAction* action = self.alertBackingNotification.otherActions[buttonIndex - 2];
		action.handler(action);
	}
}

- (void)show
{
	self.delegate = self;
	
	[super show];
}

@end

@interface LNNotification ()

@property (nonatomic, copy) NSString* appIdentifier;

@end

static LNNotificationCenter* __ln_defaultNotificationCenter;

static NSString *const _LNSettingsKey = @"LNNotificationSettingsKey";

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
	
	id _orientationHandler;
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
		
		_notificationSettings = [[[NSUserDefaults standardUserDefaults] valueForKey:_LNSettingsKey] mutableCopy];
		if(_notificationSettings == nil)
		{
			_notificationSettings = [NSMutableDictionary new];
		}
		
		_orientationHandler = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
			
			UIInterfaceOrientation newOrientation = [note.userInfo[UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue];
			
			if([UIDevice currentDevice].orientation == (UIDeviceOrientation)newOrientation)
			{
				return;
			}
		
			//Fix Apple bug of rotations.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(__bridge id)((void*)[note.userInfo[UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue])];
#pragma clang diagnostic pop
		}];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_orientationHandler];
	_orientationHandler = nil;
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
		icon = [UIImage imageNamed:@"LNNotificationsUIDefaultAppIcon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
	}
	
	_applicationMapping[appIdentifier] = @{LNAppNameKey: name, LNAppIconNameKey: icon};
	if(_notificationSettings[appIdentifier] == nil)
	{
		[self _setSettings:defaultSettings enabled:YES forAppIdentifier:appIdentifier];
	}
}

- (void)clearPendingNotificationsForApplicationIdentifier:(NSString*)appIdentifier;
{
	[_pendingNotifications filterUsingPredicate:[NSPredicate predicateWithFormat:@"appIdentifier != %@", appIdentifier]];
}

- (void)clearAllPendingNotifications;
{
	[_pendingNotifications removeAllObjects];
}

- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifier
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
		pendingNotification.appIdentifier = appIdentifier;
		
		if([_notificationSettings[appIdentifier][LNAppAlertStyleKey] unsignedIntegerValue] == LNNotificationAlertStyleAlert)
		{
			LNNotificationAlertView* alert = [[LNNotificationAlertView alloc] initWithTitle:pendingNotification.title message:pendingNotification.message delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil];
			
			if(pendingNotification.defaultAction)
			{
				[alert addButtonWithTitle:pendingNotification.defaultAction.title];
			}
			
			[pendingNotification.otherActions enumerateObjectsUsingBlock:^(LNNotificationAction* alertAction, NSUInteger idx, BOOL *stop) {
				[alert addButtonWithTitle:alertAction.title];
			}];
			
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
	
	void(^block)(void) = ^ {
		_currentlyAnimating = NO;
		
		[self _handleBannerCanChange];
		
		[self _handlePendingNotifications];
	};
	
	if(_pendingNotifications.count == 0)
	{
		if(![_notificationWindow isNotificationViewShown])
		{
			_currentlyAnimating = NO;
			
			//Clean up notification window.
			_notificationWindow.hidden = YES;
			_notificationWindow = nil;
			
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

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[_currentAudioPlayer stop];
	_currentAudioPlayer = nil;
	[[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
