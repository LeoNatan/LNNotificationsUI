//
//  LNNotificationSettingsController.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/18/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotificationSettingsController.h"
#import "LNNotificationCenter.h"
#import "LNNotificationAppSettings_Private.h"
#import "LNNotificationsAppSettingsController.h"

@interface LNNotificationSettingsController ()

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@interface _LNDetailCell : UITableViewCell @end
@implementation _LNDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

@end

@interface LNNotificationCenter ()

- (NSDictionary*)_applicationsMapping;
- (NSDictionary*)_notificationSettings;

@end

@implementation LNNotificationSettingsController
{
	NSDictionary* _mapping;
	NSArray* _includedApps;
	NSArray* _excludedApps;
	
	LNNotificationsAppSettingsController* _embeddedAppSettingsController;
}

- (instancetype)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	[self _commonInit];
	
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nil bundle:nibBundleOrNil];
	
	[self _commonInit];

	return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self _commonInit];
	
	return self;
}

- (void)_commonInit
{
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"appCell"];
	[self.tableView registerClass:[_LNDetailCell class] forCellReuseIdentifier:@"appDetailCell"];
	
	self.navigationItem.title = NSLocalizedString(@"Notifications", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sectionCount = 0;
	
	if(_includedApps.count > 0)
	{
		sectionCount++;
	}
	
	if(_excludedApps.count > 0)
	{
		sectionCount++;
	}
	
	return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(_includedApps.count == 0)
	{
		return _excludedApps.count;
	}
	else if(_excludedApps.count == 0)
	{
		return _includedApps.count;
	}
	else
	{
		if(section == 0)
		{
			return _includedApps.count;
		}
		else
		{
			return _excludedApps.count;
		}
	}
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(_includedApps.count == 0)
	{
		return NSLocalizedString(@"Do Not Include", @"");
	}
	else if(_excludedApps.count == 0)
	{
		return NSLocalizedString(@"Include", @"");
	}
	else
	{
		if(section == 0)
		{
			return NSLocalizedString(@"Include", @"");
		}
		else
		{
			return NSLocalizedString(@"Do Not Include", @"");
		}
	}
}

- (NSString*)_settingsDescriptionForApp:(NSDictionary*)app
{
	if([app[LNNotificationsDisabledKey] boolValue] == YES)
	{
		return nil;
	}
	
	NSMutableString* val = [NSMutableString new];
	
	if([app[LNAppSoundsKey] boolValue] == YES)
	{
		[val appendString:NSLocalizedString(@"Sounds", @"")];
	}
	
	if([app[LNAppAlertStyleKey] unsignedIntegerValue] != LNNotificationAlertStyleNone)
	{
		if(val.length > 0)
		{
			[val appendString:@", "];
		}
		
		if([app[LNAppAlertStyleKey] unsignedIntegerValue] == LNNotificationAlertStyleBanner)
		{
			[val appendString:NSLocalizedString(@"Banners", @"")];
		}
		else if([app[LNAppAlertStyleKey] unsignedIntegerValue] == LNNotificationAlertStyleAlert)
		{
			[val appendString:NSLocalizedString(@"Alerts", @"")];
		}
	}
	
	if(val.length == 0)
	{
		return nil;
	}
	
	return val;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"appDetailCell" forIndexPath:indexPath];
	
	NSDictionary* app;
 
	if(indexPath.section == 1 || _includedApps.count == 0)
	{
		app = _excludedApps[indexPath.row];
	}
	else if(indexPath.section == 0 && _includedApps.count > 0)
	{
		app = _includedApps[indexPath.row];
	}
	
	cell.textLabel.text = app[LNAppNameKey];
	cell.detailTextLabel.text = [self _settingsDescriptionForApp:app];
	
	UIImage* image = app[LNAppIconNameKey];
	
	CGSize imageSize = CGSizeMake(30, 30);
	if(!CGSizeEqualToSize(image.size, imageSize))
	{
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, image.scale);
		CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
		[image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
		cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	cell.imageView.layer.masksToBounds = YES;
	cell.imageView.layer.cornerRadius = 4.6875;
	cell.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
	cell.imageView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_mapping = [[LNNotificationCenter defaultCenter] _applicationsMapping];
	NSDictionary* settings = [[LNNotificationCenter defaultCenter] _notificationSettings];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary new];
	
	[_mapping enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* obj, BOOL *stop) {
		NSMutableDictionary* app = [obj mutableCopy];
		[app addEntriesFromDictionary:settings[key]];
		dictionary[key] = app;
	}];
	
	_mapping = dictionary;
	
	_includedApps = [[_mapping.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"LNNotificationsDisabledKey = NULL OR LNNotificationsDisabledKey = NO"]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:LNAppNameKey ascending:YES]]];
	_excludedApps = [[_mapping.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"LNNotificationsDisabledKey = YES"]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:LNAppNameKey ascending:YES]]];
	
	if(_mapping.count == 1)
	{
		[self _embeddSettingsControllerIfNeededWithAppIdentifier:_mapping.allKeys.firstObject];
	}
	else
	{
		[self.tableView reloadData];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

- (void)_embeddSettingsControllerIfNeededWithAppIdentifier:(NSString*)appIdentifier
{
	if(_embeddedAppSettingsController != nil)
	{
		return;
	}
	
	_embeddedAppSettingsController = [[LNNotificationsAppSettingsController alloc] initWithAppIdentifier:appIdentifier];
	
	[self addChildViewController:_embeddedAppSettingsController];
	
	UITableView* appSetting = _embeddedAppSettingsController.tableView;
	_embeddedAppSettingsController.view = [UITableView new];
	self.view = appSetting;
	[_embeddedAppSettingsController didMoveToParentViewController:self];
	
	self.navigationItem.title = _embeddedAppSettingsController.navigationItem.title;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self.tableView setContentInset:UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, self.bottomLayoutGuide.length)];
	[self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, self.bottomLayoutGuide.length)];
	
//	_embeddedAppSettingsController.tableView.frame = self.tableView.bounds;
//	_embeddedAppSettingsController.tableView.alwaysBounceVertical = YES;
//	
//	[self.tableView bringSubviewToFront:_embeddedAppSettingsController.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary* app;
	
	if(_includedApps.count == 0)
	{
		app = _excludedApps[indexPath.row];
	}
	else if(_excludedApps.count == 0)
	{
		app = _includedApps[indexPath.row];
	}
	else
	{
		if(indexPath.section == 0)
		{
			app = _includedApps[indexPath.row];
		}
		else
		{
			app = _excludedApps[indexPath.row];
		}
	}
	
	LNNotificationsAppSettingsController* appSettings = [[LNNotificationsAppSettingsController alloc] initWithAppIdentifier:[_mapping allKeysForObject:app].firstObject];
	[self.navigationController pushViewController:appSettings animated:YES];
}


@end
