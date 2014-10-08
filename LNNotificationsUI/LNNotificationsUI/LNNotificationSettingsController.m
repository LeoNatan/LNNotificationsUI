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

@interface _LNDetailCell : UITableViewCell @end
@implementation _LNDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

@end

@interface LNNotificationCenter ()

- (NSDictionary*)_applicationsMapping;

@end

@implementation LNNotificationSettingsController
{
	NSDictionary* _mapping;
	NSArray* _includedApps;
	NSArray* _excludedApps;
}

- (instancetype)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"appDetailCell" forIndexPath:indexPath];
	
	NSDictionary* app = _includedApps[indexPath.row];
	
	cell.textLabel.text = app[LNAppNameKey];
//	cell.detailTextLabel.text = @"alasda";
	cell.imageView.image = app[LNAppIconNameKey];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_mapping = [[LNNotificationCenter defaultCenter] _applicationsMapping];
	
	_includedApps = [_mapping.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"LNNotificationsDisabledKey = NULL OR LNNotificationsDisabledKey = NO"]];
	_excludedApps = [_mapping.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"LNNotificationsDisabledKey = YES"]];
	
	[self.tableView reloadData];
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
