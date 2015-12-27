//
//  LNNotificationsAppSettingsController.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/19/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotificationsAppSettingsController.h"
#import "LNNotificationCenter.h"
#import "LNNotificationAppSettings_Private.h"

@interface _LNTintedLabel : UILabel @end
@implementation _LNTintedLabel

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		[self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
		[self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisVertical];
		self.font = [UIFont systemFontOfSize:12];
		self.textAlignment = NSTextAlignmentCenter;
		self.layer.cornerRadius = 9;
	}
	return self;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	self.textColor = self.tintColor;
	self.layer.borderColor = self.tintColor.CGColor;
}

- (void)tintColorDidChange
{
	[super tintColorDidChange];
	
	self.textColor = self.tintColor;
	self.layer.borderColor = self.tintColor.CGColor;
}

- (CGSize)intrinsicContentSize
{
	CGSize size = [super intrinsicContentSize];
	
	return CGSizeMake(size.width + 30, size.height + 4);
}

@end

@protocol _LNNotificationAlertStyleDelegate <NSObject>

- (void)alertStyleDidChange:(LNNotificationAlertStyle)alertStyle;

@end

@interface LNNotificationAlertStyleCell : UITableViewCell

@property (nonatomic, weak) id<_LNNotificationAlertStyleDelegate> alertStyleDelegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier alertStyle:(LNNotificationAlertStyle)alertStyle;

@end
@implementation LNNotificationAlertStyleCell
{
	UILabel* _noneLabel;
	UILabel* _bannersLabel;
	UILabel* _alertsLabel;
	
	UIButton* none;
	UIButton* banner;
	UIButton* alert;
	
	LNNotificationAlertStyle _alertStyle;
}

- (UIButton*)_buttonWithImageName:(NSString*)imageName
{
	UIButton* rv = [UIButton buttonWithType:UIButtonTypeSystem];
	rv.translatesAutoresizingMaskIntoConstraints = NO;
	[rv setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
	[rv setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisVertical];
	[rv setImage:[UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[rv addTarget:self action:@selector(_alertStyleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

	return rv;
}

- (IBAction)_alertStyleButtonTapped:(id)sender
{
	if(sender == none)
	{
		_alertStyle = LNNotificationAlertStyleNone;
	}
	else if(sender == banner)
	{
		_alertStyle = LNNotificationAlertStyleBanner;
	}
	else if(sender == alert)
	{
		_alertStyle = LNNotificationAlertStyleAlert;
	}
	
	[self _updateLabelsAccordingToStyle];
	
	[self.alertStyleDelegate alertStyleDidChange:_alertStyle];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier alertStyle:(LNNotificationAlertStyle)alertStyle
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
	
	UIView* cv = self.contentView;
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cv]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cv)]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cv)]];
	
	none = [self _buttonWithImageName:@"LNNotificationsUIAlertStyleNone"];
	banner = [self _buttonWithImageName:@"LNNotificationsUIAlertStyleBanner"];
	alert = [self _buttonWithImageName:@"LNNotificationsUIAlertStyleAlert"];
	
	[self.contentView addSubview:none];
	[self.contentView addSubview:banner];
	[self.contentView addSubview:alert];
	
	if([UIVisualEffectView class])
	{
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[none(==banner)]-[banner(==alert)]-[alert(==none)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(none, banner, alert)]];
	}
	else
	{
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[none(==banner)]-55-[banner(==alert)]-55-[alert(==none)]-25-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(none, banner, alert)]];
	}
	
	_noneLabel = [_LNTintedLabel new];
	_noneLabel.text = NSLocalizedString(@"None", @"");
	
	_bannersLabel = [_LNTintedLabel new];
	_bannersLabel.text = NSLocalizedString(@"Banners", @"");
	
	_alertsLabel = [_LNTintedLabel new];
	_alertsLabel.text = NSLocalizedString(@"Alerts", @"");
	
	[self.contentView addSubview:_noneLabel];
	[self.contentView addSubview:_bannersLabel];
	[self.contentView addSubview:_alertsLabel];
	
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[none(==banner)]-12-[_noneLabel]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(none, banner, alert, _noneLabel)]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[banner(==alert)]-12-[_bannersLabel]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(none, banner, alert, _bannersLabel)]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[alert(==none)]-12-[_alertsLabel]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(none, banner, alert, _alertsLabel)]];
	
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_noneLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:none attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bannersLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:banner attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_alertsLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alert attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	
	_alertStyle = alertStyle;
	[self _updateLabelsAccordingToStyle];
	
	[self.contentView setNeedsUpdateConstraints];
	
	return self;
}

- (void)_updateLabelsAccordingToStyle
{
	_noneLabel.layer.borderWidth = 0;
	_bannersLabel.layer.borderWidth = 0;
	_alertsLabel.layer.borderWidth = 0;
	
	switch (_alertStyle)
	{
		case LNNotificationAlertStyleNone:
			_noneLabel.layer.borderWidth = 1;
			break;
		case LNNotificationAlertStyleBanner:
			_bannersLabel.layer.borderWidth = 1;
			break;
		case LNNotificationAlertStyleAlert:
			_alertsLabel.layer.borderWidth = 1;
			break;
		default:
			break;
	}
}

@end

@interface LNNotificationCenter ()

- (NSDictionary*)_applicationsMapping;
- (NSDictionary*)_notificationSettings;
- (void)_setSettingsDictionary:(NSDictionary*)settings forAppIdentifier:(NSString*)appIdentifier;

@end

@interface LNNotificationsAppSettingsController () <_LNNotificationAlertStyleDelegate> @end

@implementation LNNotificationsAppSettingsController
{
	NSString* _appId;
	NSDictionary* _app;
	
	NSMutableDictionary* _settings;
	
	LNNotificationAlertStyle _alertStyle;
	
	LNNotificationAlertStyleCell* _alertStyleCell;
	
	__weak UITableView* _originalTableView;
}

- (instancetype)initWithAppIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	_appId = identifier;
	_app = [[LNNotificationCenter defaultCenter] _applicationsMapping][identifier];
	_settings = [[[LNNotificationCenter defaultCenter] _notificationSettings][identifier] mutableCopy];
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"appCell"];
	self.tableView.estimatedRowHeight = 180;
	
	_alertStyleCell = [[LNNotificationAlertStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alertStyleCell" alertStyle:[_settings[LNAppAlertStyleKey] unsignedIntegerValue]];
	_alertStyleCell.alertStyleDelegate = self;
	
	self.navigationItem.title = _app[LNAppNameKey];
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_originalTableView = self.tableView;
}

- (void)alertStyleDidChange:(LNNotificationAlertStyle)alertStyle
{
	_settings[LNAppAlertStyleKey] = @(alertStyle);
	
	[[LNNotificationCenter defaultCenter] _setSettingsDictionary:_settings forAppIdentifier:_appId];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if([_settings[LNNotificationsDisabledKey] boolValue] == YES)
	{
		return 1;
	}
	
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 2)
	{
		return NSLocalizedString(@"Alert Style", @"");
	}
	
	return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(section == 2)
	{
		return NSLocalizedString(@"Alerts require an action before proceeding.\nBanners appear at the top of the screen and go away automatically.", @"");
	}
	
	return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* cellId;
	
	switch (indexPath.section)
	{
		case 0:
		case 1:
			cellId = @"appCell";
			break;
			
		default:
			cellId = @"alertStyleCell";
			break;
	}
	
	UITableViewCell* cell;
	
	if(indexPath.section == 2)
	{
		cell = _alertStyleCell;
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
	}
	
	switch (indexPath.section)
	{
		case 0:
		{
			cell.textLabel.text = NSLocalizedString(@"Allow Notifications", @"");
			
			UISwitch* sw = [UISwitch new];
			sw.on = [_settings[LNNotificationsDisabledKey] boolValue] == NO;
			[sw addTarget:self action:@selector(_didToggleEnableDisable:) forControlEvents:UIControlEventValueChanged];
			
			cell.accessoryView = sw;
		}	break;
			
		case 1:
		{
			cell.textLabel.text = NSLocalizedString(@"Sounds", @"");
			
			UISwitch* sw = [UISwitch new];
			sw.on = [_settings[LNAppSoundsKey] boolValue] == YES;
			[sw addTarget:self action:@selector(_didToggleSoundEnableDisable:) forControlEvents:UIControlEventValueChanged];
			
			cell.accessoryView = sw;
		}	break;
			
		default:
			cell.accessoryView = nil;
			break;
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([UIVisualEffectView class] != nil)
	{
		//iOS 8.0 and above - table view will calculate cell height according to auto layout constraints.
		return UITableViewAutomaticDimension;
	}
	
	switch (indexPath.section)
	{
		case 2:
			return 160.0;
		default:
			return 44.0;
	}
}

- (void)_didToggleEnableDisable:(UISwitch*)toggle
{
	_settings[LNNotificationsDisabledKey] = @(!toggle.isOn);
	
	[[LNNotificationCenter defaultCenter] _setSettingsDictionary:_settings forAppIdentifier:_appId];
	
	if(toggle.isOn)
	{
		[_originalTableView beginUpdates];
		[_originalTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
		[_originalTableView endUpdates];
	}
	else
	{
		[_originalTableView beginUpdates];
		[_originalTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
		[_originalTableView endUpdates];
	}
}

- (void)_didToggleSoundEnableDisable:(UISwitch*)toggle
{
	_settings[LNAppSoundsKey] = @(toggle.isOn);
	
	[[LNNotificationCenter defaultCenter] _setSettingsDictionary:_settings forAppIdentifier:_appId];
}


@end
