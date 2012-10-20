
// Lytics.m
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "Lytics.h"
#import "LyticsSettings.h"
#import "DeviceInfo.h"
#import "Event.h"
#import "EventQueue.h"
#import "ConnectionQueue.h"

#import "JSONKit.h"

#import <UIKit/UIKit.h>

/// Utilities for encoding and decoding URL arguments.
/// This code is from the project google-toolbox-for-mac
@interface NSString (GTMNSStringURLArgumentsAdditions)

/// Returns a string that is escaped properly to be a URL argument.
//
/// This differs from stringByAddingPercentEscapesUsingEncoding: in that it
/// will escape all the reserved characters (per RFC 3986
/// <http://www.ietf.org/rfc/rfc3986.txt>) which
/// stringByAddingPercentEscapesUsingEncoding would leave.
///
/// This will also escape '%', so this should not be used on a string that has
/// already been escaped unless double-escaping is the desired result.
- (NSString*)gtm_stringByEscapingForURLArgument;

/// Returns the unescaped version of a URL argument
//
/// This has the same behavior as stringByReplacingPercentEscapesUsingEncoding:,
/// except that it will also convert '+' to space.
- (NSString*)gtm_stringByUnescapingFromURLArgument;

@end

#define GTMNSMakeCollectable(cf) ((id)(cf))
#define GTMCFAutorelease(cf) ([GTMNSMakeCollectable(cf) autorelease])

@implementation NSString (GTMNSStringURLArgumentsAdditions)

- (NSString*)gtm_stringByEscapingForURLArgument {
	// Encode all the reserved characters, per RFC 3986
	// (<http://www.ietf.org/rfc/rfc3986.txt>)
	CFStringRef escaped = 
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
	return GTMCFAutorelease(escaped);
}

- (NSString*)gtm_stringByUnescapingFromURLArgument {
	NSMutableString *resultString = [NSMutableString stringWithString:self];
	[resultString replaceOccurrencesOfString:@"+"
								  withString:@" "
									 options:NSLiteralSearch
									   range:NSMakeRange(0, [resultString length])];
	return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

static Lytics *s_sharedLytics = nil;

@interface Lytics (PrivateMethods)

- (void)onTimer:(NSTimer *)timer;

- (void)didEnterBackgroundCallBack:(NSNotification *)notification;
- (void)willEnterForegroundCallBack:(NSNotification *)notification;
- (void)willTerminateCallBack:(NSNotification *)notification;

- (void)suspend;
- (void)resume;
- (void)exit;

@end

@implementation Lytics (PrivateMethods)

- (void)onTimer:(NSTimer *)timer
{
	if (isSuspended == YES)
		return;
	
	double currTime = CFAbsoluteTimeGetCurrent();
	unsentSessionLength += currTime - lastTime;
	lastTime = currTime;
	
	int duration = unsentSessionLength;
	[[ConnectionQueue sharedInstance] updateSession];
	unsentSessionLength -= duration;
	
    if (eventQueue.count > 0)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)didEnterBackgroundCallBack:(NSNotification *)notification
{
	LYTICS_LOG(@"Lytics didEnterBackgroundCallBack");
	[self suspend];
}

- (void)willEnterForegroundCallBack:(NSNotification *)notification
{
	LYTICS_LOG(@"Lytics willEnterForegroundCallBack");
	[self resume];
}

- (void)willTerminateCallBack:(NSNotification *)notification
{
	LYTICS_LOG(@"Lytics willTerminateCallBack");
	[self exit];
}

- (void)suspend
{
	isSuspended = YES;
	
    if (eventQueue.count > 0)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
	
	double currTime = CFAbsoluteTimeGetCurrent();
	unsentSessionLength += currTime - lastTime;
	
	int duration = unsentSessionLength;
	
	if ([[LyticsSettings generalSetting:@"end_session_on_app_focus_lost"] boolValue]) {
		[self endSession];
	}
	
	unsentSessionLength -= duration;
}

- (void)resume
{
	lastTime = CFAbsoluteTimeGetCurrent();
	
	if ([[LyticsSettings generalSetting:@"end_session_on_app_focus_lost"] boolValue]) {
		[self startSession];
	}
	
	isSuspended = NO;
}

- (void)exit
{
}

@end

@implementation Lytics

+ (Lytics *)sharedInstance
{
	if (s_sharedLytics == nil)
		s_sharedLytics = [[Lytics alloc] init];

	return s_sharedLytics;
}

- (id)init
{
	if (self = [super init])
	{
		timer = nil;
		isSuspended = NO;
		unsentSessionLength = 0;
        eventQueue = [[EventQueue alloc] init];
		
		[DeviceInfo registerGlobalAccessors];
		
		[LyticsSettings setAccessorForGlobalKey:@"SESSION_TIME_KEY" target:self selector:@selector(sessionTime)];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(didEnterBackgroundCallBack:) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(willEnterForegroundCallBack:) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(willTerminateCallBack:) 
													 name:UIApplicationWillTerminateNotification 
												   object:nil];
	}
	return self;
}

- (void)start:(NSString *)accountID withHost:(NSString *)appHost
{
	timer = [NSTimer scheduledTimerWithTimeInterval:30.0
											 target:self
										   selector:@selector(onTimer:)
										   userInfo:nil
											repeats:YES];
	lastTime = CFAbsoluteTimeGetCurrent();
	sessionStartTimestamp = time(NULL);
	[[ConnectionQueue sharedInstance] setAccountID:accountID];
	[[ConnectionQueue sharedInstance] setAppHost:appHost];
	
	[self recordEvent:@"LOAD_KEY" category:@"load"];
	
	if ([[LyticsSettings generalSetting:@"start_session_on_load"] boolValue]) {
		[self startSession];
	}
}

- (void)startSession
{
	sessionStartTimestamp = time(NULL);
	[[ConnectionQueue sharedInstance] beginSession];
}

- (void)endSession
{
	[[ConnectionQueue sharedInstance] endSession];
}

- (void)recordEvent:(NSString *)key
{
    [eventQueue recordEvent:key];
    
    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordEvent:(NSString *)key category:(NSString *)category
{
    [eventQueue recordEvent:key category:category];

    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordEvent:(NSString *)key categories:(NSArray *)categories
{
    [eventQueue recordEvent:key categories:categories];

    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordEvent:(NSString *)key parameters:(NSDictionary *)parameters
{
    [eventQueue recordEvent:key parameters:parameters];

    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordEvent:(NSString *)key category:(NSString *)category parameters:(NSDictionary *)parameters
{
	[eventQueue recordEvent:key category:category parameters:parameters];
	
    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordEvent:(NSString *)key categories:(NSArray *)categories parameters:(NSDictionary *)parameters
{
	[eventQueue recordEvent:key categories:categories parameters:parameters];
	
    if (eventQueue.count >= 5)
        [[ConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (NSNumber*)sessionTime
{
	return [NSNumber numberWithLong:(time(NULL) - sessionStartTimestamp)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
	
	if (timer)
    {
        [timer invalidate];
        timer = nil;
    }

    [eventQueue release];
	
	[super dealloc];
}

@end
