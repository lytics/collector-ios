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

#import <Foundation/Foundation.h>

@interface ConnectionQueue : NSObject
{
	NSMutableArray *queue_;
	NSURLConnection *connection_;
	UIBackgroundTaskIdentifier bgTask_;
	NSString *accountID;
	NSString *appHost;
}

@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *appHost;

+ (ConnectionQueue *)sharedInstance;

// Commit any event additions made to the queue so they will be passed to the
// server as soon as possible. Commit is called by all other ConnectionQueue
// methods that add events unless explicitly stated so it is generally not
// necessary to call it yourself.
- (void)commit;

// Send the begin session event, if enabled.
- (void)beginSession;

// Send the session update event, if enabled.
- (void)updateSession;

// Send the session ended event, if enabled.
- (void)endSession;

// Send the given array of events.
- (void)recordEvents:(NSArray *)events;

@end
