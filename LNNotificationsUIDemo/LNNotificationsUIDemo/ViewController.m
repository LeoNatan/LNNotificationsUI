//
//  ViewController.m
//  LNNotificationsUIDemo
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "ViewController.h"
#import <LNNotificationsUI/LNNotificationsUI.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)queueMoreButtonTapped:(id)sender {
	LNNotification* notification = [LNNotification notificationWithMessage:@"Looks just like the native iOS7 & iOS8 banner notifications!"];
	notification.title = @"First Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
	
	notification = [LNNotification notificationWithMessage:@"You can customize most parts of the notification messages."];
	notification.title = @"Another Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
	
	notification = [LNNotification notificationWithMessage:@"You can swipe notifications to dismiss them."];
	notification.title = @"And Another";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
	
	notification = [LNNotification notificationWithMessage:@"Pretty cool, isn't it?"];
	notification.title = @"Last One, I Promise!";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
	
	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Leo" icon:nil];
	
	LNNotification* notification = [LNNotification notificationWithMessage:@"Welcome to LNNotificationsUI!"];
	notification.title = @"Hello World!";
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)notificationWasTapped:(NSNotification*)notification
{
	LNNotification* tappedNotification = notification.object;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:tappedNotification.title message:tappedNotification.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

@end
