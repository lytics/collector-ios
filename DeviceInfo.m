//
// DeviceInfo.h
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "DeviceInfo.h"
#import "LyticsSettings.h"

#import "JSONKit.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation DeviceInfo

+ (NSString *)device
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)osVersion
{
	return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*)os
{
	return @"iOS";
}

+ (NSString *)carrier
{
	if (NSClassFromString(@"CTTelephonyNetworkInfo"))
	{
		CTTelephonyNetworkInfo *netinfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
		CTCarrier *carrier = [netinfo subscriberCellularProvider];
		return [carrier carrierName];
	}
	
	return nil;
}

+ (id)carrierOrNULL
{
	id ret = [DeviceInfo carrier];
	
	if (ret == nil) {
		ret = [NSNull null];
	}
	return  ret;
}

+ (NSString *)resolution
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGFloat scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.f;
	CGSize res = CGSizeMake(bounds.size.width * scale, bounds.size.height * scale);
	NSString *result = [NSString stringWithFormat:@"%gx%g", res.width, res.height];
	
	return result;
}

+ (NSString *)locale
{
	return [[NSLocale currentLocale] localeIdentifier];
}

+ (NSString *)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
}

+ (NSNumber *)timestamp
{
	return [NSNumber numberWithLong:time(NULL)];
}

+ (NSString *)metrics
{
	NSMutableDictionary* dict = [[[NSMutableDictionary alloc] initWithCapacity:7] autorelease];
	
	[dict setObject:[DeviceInfo device] forKey:[LyticsSettings parameterNameForKey:@"DEVICE_KEY"]];
	[dict setObject:[DeviceInfo osVersion] forKey:[LyticsSettings parameterNameForKey:@"OS_VERSION_KEY"]];
	[dict setObject:[DeviceInfo os] forKey:[LyticsSettings parameterNameForKey:@"OS_KEY"]];
	NSString* carrier = [DeviceInfo carrier];
	if (carrier) {
		[dict setObject:carrier forKey:[LyticsSettings parameterNameForKey:@"CARRIER_KEY"]];
	}
	[dict setObject:[DeviceInfo resolution] forKey:[LyticsSettings parameterNameForKey:@"RESOLUTION_KEY"]];
	[dict setObject:[DeviceInfo locale] forKey:[LyticsSettings parameterNameForKey:@"LOCALE_KEY"]];
	[dict setObject:[DeviceInfo appVersion] forKey:[LyticsSettings parameterNameForKey:@"APP_VERSION_KEY"]];
	[dict setObject:[DeviceInfo timestamp] forKey:@"TIMESTAMP_KEY"];
	
	return [dict JSONString];
}

+ (void)registerGlobalAccessors
{
	id target = [DeviceInfo class];
	[LyticsSettings setAccessorForGlobalKey:@"DEVICE_KEY" target:target selector:@selector(device)];
	[LyticsSettings setAccessorForGlobalKey:@"OS_VERSION_KEY" target:target selector:@selector(osVersion)];
	[LyticsSettings setAccessorForGlobalKey:@"OS_KEY" target:target selector:@selector(os)];
	[LyticsSettings setAccessorForGlobalKey:@"CARRIER_KEY" target:target selector:@selector(carrierOrNULL)];
	[LyticsSettings setAccessorForGlobalKey:@"RESOLUTION_KEY" target:target selector:@selector(resolution)];
	[LyticsSettings setAccessorForGlobalKey:@"LOCALE_KEY" target:target selector:@selector(locale)];
	[LyticsSettings setAccessorForGlobalKey:@"APP_VERSION_KEY" target:target selector:@selector(appVersion)];
	[LyticsSettings setAccessorForGlobalKey:@"TIMESTAMP_KEY" target:target selector:@selector(timestamp)];
}

@end
