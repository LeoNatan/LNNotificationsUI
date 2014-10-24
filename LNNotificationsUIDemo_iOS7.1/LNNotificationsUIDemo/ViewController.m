//
//  ViewController.m
//  LNNotificationsUIDemo
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "ViewController.h"
#import "LNNotificationsUI_iOS7.1.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)queueMoreButtonTapped:(id)sender {
	LNNotification* notification = [LNNotification notificationWithMessage:@"Looks just like the native iOS 7 and iOS 8 banner notifications!"];
	notification.title = @"First Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24];
	notification.soundName = @"demo.aiff";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
	
	notification = [LNNotification notificationWithMessage:@"You can customize most parts of the notification messages."];
	notification.title = @"Another Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	notification.soundName = @"demo.aiff";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"456"];
	
	notification = [LNNotification notificationWithMessage:@"You can swipe notifications up to dismiss them."];
	notification.title = @"And Another";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	notification.soundName = @"demo.aiff";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"789"];
	
	notification = [LNNotification notificationWithMessage:@"Pretty cool, isn't it?"];
	notification.title = @"Last One";
	notification.soundName = @"demo.aiff";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

- (IBAction)changeStyleButtonTapped:(id)sender {
	[LNNotificationCenter defaultCenter].notificationsBannerStyle = ![LNNotificationCenter defaultCenter].notificationsBannerStyle;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
	
	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Notifications Demp App 1" icon:nil defaultSettings:LNNotificationDefaultAppSettings];
	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"456" name:@"Notifications Demp App 2" icon:nil defaultSettings:LNNotificationDefaultAppSettings];
	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"789" name:@"Notifications Demp App 3" icon:nil defaultSettings:LNNotificationDefaultAppSettings];
	
	LNNotification* notification = [LNNotification notificationWithMessage:@"Welcome to LNNotificationsUI!"];
	notification.title = @"Hello World!";
	notification.soundName = @"demo.aiff";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)notificationWasTapped:(NSNotification*)notification
{
	LNNotification* tappedNotification = notification.object;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:tappedNotification.title message:@"Notification was tapped!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
