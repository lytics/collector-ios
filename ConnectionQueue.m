//
// ConnectionQueue.h
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "Lytics.h"
#import "ConnectionQueue.h"
#import "Event.h"
#import "LyticsSettings.h"

static ConnectionQueue *s_sharedConnectionQueue = nil;

@implementation ConnectionQueue : NSObject

@synthesize accountID;
@synthesize appHost;

+ (ConnectionQueue *)sharedInstance
{
	if (s_sharedConnectionQueue == nil)
		s_sharedConnectionQueue = [[ConnectionQueue alloc] init];
	
	return s_sharedConnectionQueue;
}

- (id)init
{
	if (self = [super init])
	{
		queue_ = [[NSMutableArray alloc] init];
		connection_ = nil;
        bgTask_ = UIBackgroundTaskInvalid;
        accountID = nil;
        appHost = nil;
	}
	return self;
}

- (void)commit
{
    if (connection_ != nil || bgTask_ != UIBackgroundTaskInvalid || [queue_ count] == 0)
        return;
	
    UIApplication *app = [UIApplication sharedApplication];
    bgTask_ = [app beginBackgroundTaskWithExpirationHandler:^{
		[app endBackgroundTask:bgTask_];
		bgTask_ = UIBackgroundTaskInvalid;
    }];
	
	NSString *urlString = [NSString stringWithFormat:@"%@/c/%@", self.appHost, self.accountID];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	//	[request setTimeoutInterval:10]; //timeout after 10 seconds.
	
	id dataObject = [queue_ objectAtIndex:0];
	
//	LYTICS_LOG(@"EVENT: %@",dataObject);
	
	NSData* requestBodyData = [dataObject JSONData];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%du", requestBodyData.length] forHTTPHeaderField:@"Content-length"];
	[request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
	[request setValue:@"iOS" forHTTPHeaderField:@"Origin"];
	
	[request setHTTPBody:requestBodyData];
	
    connection_ = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)beginSession
{
	if ([[LyticsSettings defaultEventKeys] containsObject:@"LOAD_KEY"]) {
		Event* event = [[Event alloc] init];
//		event.timestamp = time(NULL);
		event.key = @"LOAD_KEY";
		event.categories = [NSArray arrayWithObject:@"load"];
		
		[queue_ addObject:event];
		[self commit];
		[event release];
	}
}

- (void)updateSession
{
	if ([[LyticsSettings defaultEventKeys] containsObject:@"SESSION_UPDATE_KEY"]) {
		Event* event = [[Event alloc] init];
//		event.timestamp = time(NULL);
		event.key = @"SESSION_UPDATE_KEY";
		event.categories = nil;
		
		[queue_ addObject:event];
		[self commit];
		[event release];
	}
}

- (void)endSession
{
	if ([[LyticsSettings defaultEventKeys] containsObject:@"SESSION_END_KEY"]) {
		Event* event = [[Event alloc] init];
//		event.timestamp = time(NULL);
		event.key = @"SESSION_END_KEY";
		event.categories = nil;
		
		[queue_ addObject:event];
		[self commit];
		[event release];
	}
}

- (void)recordEvents:(NSArray *)events
{
	[queue_ addObject:events];
	[self commit];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	LYTICS_LOG(@"ok -> %@", [queue_ objectAtIndex:0]);
	
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask_ != UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:bgTask_];
        bgTask_ = UIBackgroundTaskInvalid;
    }
	
    connection_ = nil;
	
    [queue_ removeObjectAtIndex:0];
	
    [self commit];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err
{
	LYTICS_LOG(@"error -> %@", [queue_ objectAtIndex:0]);
	LYTICS_LOG(@"%@",err);
	
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask_ != UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:bgTask_];
        bgTask_ = UIBackgroundTaskInvalid;
    }
	
    connection_ = nil;
}

- (void)dealloc
{
	[super dealloc];
	
	if (connection_)
		[connection_ cancel];
	
	[queue_ release];
	
	self.accountID = nil;
	self.appHost = nil;
}

@end
