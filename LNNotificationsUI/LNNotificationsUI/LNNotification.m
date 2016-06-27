//
//  LNNotification.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotification.h"

@interface LNNotificationAction ()

@property (nonatomic, copy, readwrite) NSString* title;
@property(nonatomic, copy, readwrite) void (^handler)(LNNotificationAction* action);

@end

@implementation LNNotificationAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(LNNotificationAction *))handler
{
	LNNotificationAction* action = [self new];
	action.title = title;
	action.handler = handler;
	
	return action;
}

@end

@interface LNNotification ()

@property (nonatomic, copy) NSString* appIdentifier;
@property (nonatomic, copy) NSDictionary* userInfo;

@end

@implementation LNNotification

+ (BOOL)supportsSecureCoding
{
	return YES;
}

+ (instancetype)notificationWithMessage:(NSString*)message
{
	return [[LNNotification alloc] initWithMessage:message title:nil icon:nil date:[NSDate date]];
}

+ (instancetype)notificationWithMessage:(NSString*)message title:(NSString*)title
{
	return [[LNNotification alloc] initWithMessage:message title:title icon:nil date:[NSDate date]];
}

+ (instancetype)notificationWithMessage:(NSString*)message title:(NSString*)title icon:(UIImage*)icon date:(NSDate*)date
{
	return [[LNNotification alloc] initWithMessage:message title:title icon:icon date:date];
}

- (instancetype)init
{
	return [self initWithMessage:nil title:nil icon:nil date:[NSDate date]];
}

- (instancetype)initWithMessage:(NSString*)message
{
	return [self initWithMessage:message title:nil icon:nil date:[NSDate date]];
}

- (instancetype)initWithMessage:(NSString *)message title:(NSString *)title
{
	return [self initWithMessage:message title:title icon:nil date:[NSDate date]];
}

- (instancetype)initWithMessage:(NSString *)message title:(NSString *)title icon:(UIImage *)icon date:(NSDate *)date
{
	self = [super init];
	
	if(self)
	{
		self.title = title;
		self.message = message;
		self.icon = icon;
		self.date = date;
		self.displaysWithRelativeDateFormatting = YES;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	LNNotification* copy = [[LNNotification allocWithZone:zone] initWithMessage:self.message title:self.title icon:self.icon date:self.date];
	copy.displaysWithRelativeDateFormatting = self.displaysWithRelativeDateFormatting;
	copy.defaultAction = self.defaultAction;
	copy.otherActions = self.otherActions;
	copy.soundName = self.soundName;
	
	return copy;
}

- (NSString*)description
{
	NSMutableString* description = [[super description] mutableCopy];
	
	if(self.appIdentifier)
	{
		[description appendFormat:@" appIdentifier: %@", self.appIdentifier];
	}
	
	[description appendFormat:@" ; data: {\n\ttitle = %@\n\tmessage = %@\n\tdate = %@\n\tdisplaysWithRelativeDateFormatting = %@\n\tsoundName = %@\n}", self.title.description, self.message.description, self.date.description, self.displaysWithRelativeDateFormatting ? @"YES" : @"NO", self.soundName.description];
	
	return description;
}

@end
