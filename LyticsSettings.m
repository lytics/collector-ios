//
//  LyticsSettings.m
//
//  Created by Mathew Polzin on 10/17/12.
//

#import "LyticsSettings.h"

static LyticsSettings* _lyticsSettings = nil;

@interface LyticsSettings (PrivateMethods)

// Convenience method; passes method call on to settings dictionary.
- (id)objectForKey:(NSString*)key;

// Convenience method; passes method call on to shared LyticsSettings object.
+ (id)objectForKey:(NSString*)key;

@end

@implementation LyticsSettings (PrivateMethods)

- (id)objectForKey:(NSString*)key
{
	return [self.settings objectForKey:key];
}

+ (id)objectForKey:(NSString*)key
{
	[LyticsSettings loadSettings];
	return [_lyticsSettings objectForKey:key];
}

@end

@implementation LyticsSettings

@synthesize settings,globalParameterGetters;

- (id)init
{
	self = [super init];
	
	if (self) {
		NSString* fpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LyticsSettings.plist"];
		settings = [[NSDictionary alloc] initWithContentsOfFile:fpath];
		
		globalParameterGetters = [[NSMutableDictionary alloc] initWithCapacity:[[settings objectForKey:@"global_keys"] count]];
	}
	
	return self;
}

+ (void)loadSettings
{
	if (_lyticsSettings == nil) {
		_lyticsSettings = [[LyticsSettings alloc] init];
	}
}

+ (id)generalSetting:(NSString*)settingName
{
	return [[LyticsSettings objectForKey:@"general_settings"] objectForKey:settingName];
}

+ (NSDictionary*)globalKeys
{
	return [[LyticsSettings objectForKey:@"parameters"] objectForKey:@"global_keys"];
}

+ (NSDictionary*)localKeys
{
	return [[LyticsSettings objectForKey:@"parameters"] objectForKey:@"local_keys"];
}

+ (NSDictionary*)categories
{
	return [[LyticsSettings objectForKey:@"parameters"] objectForKey:@"categories"];
}

+ (NSArray*)keysInCategory:(NSString *)category
{
	return [[LyticsSettings categories] objectForKey:category];
}

+ (NSString*)parameterNameForKey:(NSString*)key
{
	NSString* parameterName = [[LyticsSettings globalKeys] objectForKey:key];
	if (!parameterName) {
		parameterName = [[LyticsSettings localKeys] objectForKey:key];
		
		if (!parameterName) {
			parameterName = key;
		}
	}
	return parameterName;
}

+ (void)setAccessorForGlobalKey:(NSString*)key target:(id)target selector:(SEL)getter
{
	[LyticsSettings loadSettings];
	
	NSMethodSignature* m = [target methodSignatureForSelector:getter];
	NSInvocation* i = [NSInvocation invocationWithMethodSignature:m];
	[i setSelector:getter];
	[i setTarget:target];
	[_lyticsSettings.globalParameterGetters setObject:i forKey:key];
}

+ (id)getParameterValueForGlobalKey:(NSString*)key
{
	[LyticsSettings loadSettings];
	
	NSInvocation* i = [_lyticsSettings.globalParameterGetters objectForKey:key];
	if (i == nil) {
		[NSException raise:@"InvalidKeyException" format:@"The global parameter key %@ does not have an accessor assosciated with it (via setAccessorForGlobalKey:target:selector:).", key];
	}
	return [i.target performSelector:i.selector];
}

+ (NSArray*)defaultEventKeys
{
	return [[LyticsSettings objectForKey:@"events"] objectForKey:@"default_tracked_events"];
}

+ (NSString*)eventNameForKey:(NSString*)key
{
	NSString* eventName = [[[LyticsSettings objectForKey:@"events"] objectForKey:@"keys"] objectForKey:key];
	if (!eventName) {
		eventName = key;
	}
	return eventName;
}

- (void) dealloc
{
	[globalParameterGetters release], globalParameterGetters = nil;
	[settings release], settings = nil;
	[super dealloc];
}

@end
