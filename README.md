# LNNotificationsUI

`LNNotificationsUI` is a framework for displaying notifications similar to Apple's iOS 8 and iOS 9 notifications. It is meant to complement the native look and feel, by providing a pixel-accurate (as much as possible) recreation of the notifications.

<img src="./Screenshots/Presentation.png" width="320px"/> 
<img src="./Screenshots/LNNotificationsUI.gif" height="568px"/>

See a video [here](https://vimeo.com/105395794).

<span class="badge-paypal"><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BR68NJEJXGWL6" title="Donate to this project using PayPal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal Donation Button" /></a></span>

## Features

* Native look & feel
* Support for notifications of multiple "applications"
* Customizable notifications
* Different banner styles:

<img src="./Screenshots/3.png" width="213px"/>&nbsp;
<img src="./Screenshots/style.png" width="250px"/>

* Settings for registered apps:

<img src="./Screenshots/settings1.png" width="250px"/>&nbsp;
<img src="./Screenshots/settings2.png" width="250px"/>

* Sounds support
* Xcode 6 framework

## Adding to Your Project

###Carthage

Add the following to your Cartfile:

```github "LeoNatan/LNNotificationsUI"```

###Manual

Drag the `LNNotificationsUI.xcodeproj` project to your project, and add `LNNotificationsUI.framework` to **Embedded Binaries** in your project target's **General** tab. Xcode should sort everything else on its own.

## Using the Framework

###Project Integration

First import the umbrella header file:

```objective-c
@import LNNotificationsUI;
```

###Registering Applications

Before being able to post notifications, you need to register at least one application with the system. Applications provide a way to group notifications, each with its own identifier, name and icon and other settings. For example, a productivity app with an e-mail client and a calendar may register two applications, "Mail" and "Calendar" with different icons, and other more advanced settings, such calendar notifications appearing as alerts by default.

```objective-c
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"mail_app_identifier" name:@"Mail" icon:[UIImage imageNamed:@"MailApp"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"cal_app_identifier" name:@"Calendar" icon:[UIImage imageNamed:@"CalApp"]  defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
```

**Note:** For all available options for the default settings, take a look at the `LNNotificationAppSettings` class definition. `+ [LNNotificationAppSettings defaultNotificationAppSettings]` is provided as a convenience for obtaining the default settings.

###Displaying Notifications

Now the system is ready to post notifications. Create a notification object, set the desired parameters and post it.

```objective-c
LNNotification* notification = [LNNotification notificationWithMessage:@"You've Got Mail!"];
	
[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"mail_app_identifier"];
```

**Note:** For all available notification properties, take a look at the `LNNotification` class definition.

###Notification Actions

In addition to displaying notifications, you can associate actions with each notification. Each notification has a default action, as well as other actions that can be attached to the notification. When the user taps a notification or the appropriate button, the provided handler block is called.

```objective-c
LNNotification* notification = [LNNotification notificationWithMessage:@"Welcome to LNNotificationsUI!"];
	notification.title = @"Hello World!";
	notification.soundName = @"demo.aiff";
	notification.defaultAction = [LNNotificationAction actionWithTitle:@"Default Action" handler:^(LNNotificationAction *action) {
		//Handle default action
	}];
	notification.otherActions = @[[LNNotificationAction actionWithTitle:@"Other Action 1" handler:^(LNNotificationAction *action) {
		//Handle other action here
	}], [LNNotificationAction actionWithTitle:@"Other Action 2" handler:^(LNNotificationAction *action) {
		//Handle other action here
	}]];
```
**Note:** Currently, other actions are only available when notifications are presented as alerts. Tapping on banner notifications will call the default action handler.

###Settings

To display the notification settings view controller, create an instance of `LNNotificationSettingsController`, either in code or storyboard and display it. This view controller will display all registered apps, and will allow the user to select how notifications are presented to him. If only one app is registered, its settings will appear in this view controller. If there two or more apps registered, a list of apps will appear and selecting an app will show its settings.
