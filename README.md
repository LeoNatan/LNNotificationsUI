# LNNotificationsUI

`LNNotificationsUI` is a framework for displaying notifications similar to Apple's iOS 7 and iOS 8 notifications. It is meant to complement the native look and feel, by providing a pixel-accurate (as much as possible) recreation of the notifications.

<img src="./Screenshots/Presentation.png" height="676px"/><img src="./Screenshots/LNNotificationsUI.gif" height="676px"/>

See a video [here](https://vimeo.com/105395794).

## Features

* Native look & feel
* Support for notifications of multiple "applications"
* Customizeable notifications
* Different banner styles:

<img src="./Screenshots/3.png" width="213px"/>&nbsp;
<img src="./Screenshots/style.png" width="250px"/>

* Settings for registered apps:

<img src="./Screenshots/settings1.png" width="250px"/>&nbsp;
<img src="./Screenshots/settings2.png" width="250px"/>

* Sounds support
* Xcode 6 framework

## Adding to Your Project

Drag the `LNNotificationsUI` project to your project, and add `LNNotificationsUI.framework` under **Link Binary With Libraries** in your project target.

## Using the Framework

First import the umbrella header file:

```objective-c
#import <LNNotificationsUI/LNNotificationsUI.h>
```

Before being able to post notifications, you need to register at least one "application" with the system. "Applications" are logical differenciators, each with its own identifier, name and icon. For example, a productivity app with an e-mail client and a calendar may register two applications, "Mail" and "Calendar" with different icons and default titles.

```objective-c
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"mail_app_identifier" name:@"Mail" icon:[UIImage imageNamed:@"MailApp"] defaultSettings:LNNotificationDefaultAppSettings];
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"cal_app_identifier" name:@"Calendar" icon:[UIImage imageNamed:@"CalApp"]  defaultSettings:LNNotificationDefaultAppSettings];
```

**Note:** For all available options for the default settings, take a look at the `LNNotificationAppSettings` class definition. `LNNotificationDefaultAppSettings` is provided as a convenience for default settings.

Now the system is ready to post notifications. Create a notificaiton object, set the desired parameters and post it.

```objective-c
LNNotification* notification = [LNNotification notificationWithMessage:@"You've Got Mail!"];
	
[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"mail_app_identifier"];
```

**Note:** For all available notification properties, take a look at the `LNNotification` class definition.

To listen to taps on notifications by the user, register to the ``LNNotificationWasTappedNotification`` notification. You can register for specific notification objects or for all, by passing `nil` as the object.

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
```
Use the `notification.object` to get the tapped `LNNotification` object.

```objective-c
- (void)notificationWasTapped:(NSNotification*)notification
{
	LNNotification* tappedNotification = notification.object;
	
	// Handle tap here.
}
```