# LNNotificationsUI

`LNNotificationsUI` is a framework for displaying notifications similar to Apple's iOS 7 and iOS 8 notifications. It is meant to complement the native look and feel, by providing a pixel-accurate (as much as possible) recreation of the notifications.

<img src="./Screenshots/Presentation.png" width="320px"/> 
<img src="./Screenshots/LNNotificationsUI.gif" height="568px"/>

See a video [here](https://vimeo.com/105395794).

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

Drag the `LNNotificationsUI` project to your project, and add `LNNotificationsUI.framework` under **Link Binary With Libraries** in your project target. Make sure to add `LNNotificationsUIAssets.xcassets` to your target's `Copy Bundle Resources`.

## Using the Framework

###Project Integration

First import the umbrella header file:

```objective-c
#import <LNNotificationsUI/LNNotificationsUI.h>
```

###Registering Applications

Before being able to post notifications, you need to register at least one application with the system. Applications provide a way to group notifications, each with its own identifier, name and icon and other settings. For example, a productivity app with an e-mail client and a calendar may register two applications, "Mail" and "Calendar" with different icons, and other more advanced settings, such calendar notifications appearing as alerts by default.

```objective-c
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"mail_app_identifier" name:@"Mail" icon:[UIImage imageNamed:@"MailApp"] defaultSettings:LNNotificationDefaultAppSettings];
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"cal_app_identifier" name:@"Calendar" icon:[UIImage imageNamed:@"CalApp"]  defaultSettings:LNNotificationDefaultAppSettings];
```

**Note:** For all available options for the default settings, take a look at the `LNNotificationAppSettings` class definition. `LNNotificationDefaultAppSettings` is provided as a convenience for default settings.

###Displaying Notifications

Now the system is ready to post notifications. Create a notification object, set the desired parameters and post it.

```objective-c
LNNotification* notification = [LNNotification notificationWithMessage:@"You've Got Mail!"];
	
[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"mail_app_identifier"];
```

**Note:** For all available notification properties, take a look at the `LNNotification` class definition.

###Notification Actions

In addition to displaying notifications, you can associate actions with each notification. Each notification has a default action, as well as other actions that can be attached to the notification. When the user taps a notification or the appropriate button, the provided handler block is called.

```
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

## iOS 7.0 Projects Support

iOS versions below 8.0 do not support dynamic frameworks, so adding the project as described above will not work. To use the framework, add all `.h` and `.m` files from `LNNotificationsUI\LNNotificationsUI` as well as `LNNotificationsUIAssets.xcassets` to your project, and import `LNNotificationsUI_iOS7.1.h`:

```
#import "LNNotificationsUI_iOS7.1.h"
```

You can now use the framework normally.

The framework will do its best to display as close as possible to the intended result, but some parts, such as vibrancy effects are disabled due to no iOS 7.0 public API.