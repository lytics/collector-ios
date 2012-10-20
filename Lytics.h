
// Lytics.h
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#define LYTICS_DEBUG 1

#if LYTICS_DEBUG
#   define LYTICS_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define LYTICS_LOG(...)
#endif

#define LYTICS_VERSION "1.0"

#import <Foundation/Foundation.h>

@class EventQueue;

@interface Lytics : NSObject {
	double unsentSessionLength;
	NSTimer *timer;
	double lastTime;
	BOOL isSuspended;
    EventQueue *eventQueue;
	
	time_t sessionStartTimestamp;
}

+ (Lytics *)sharedInstance;

// Start the Lytics session. The account ID and Lytics host URL are
// provided by Lytics.
- (void)start:(NSString *)accountID withHost:(NSString*)appHost;

// Use these to perform session tracking. Often it might be desirable to end
// the current session when the user puts your app in the background and start
// a new session when the user comes back to your app. Your app may be
// technically running in the background for an arbitrarily long time while the
// user does whatever else on the phone.
- (void)startSession;
- (void)endSession;

// Record event with given name and include only the fields defined in the
// special "all" category.
- (void)recordEvent:(NSString *)key;

// Record an event and include parameters from 1 or more categories (see
// LyticsSettings.plist).
- (void)recordEvent:(NSString *)key category:(NSString*)category;
- (void)recordEvent:(NSString *)key categories:(NSArray*)categories;

// Record event and include the key/value pairs in the given dictionary
// as additional parameters.
- (void)recordEvent:(NSString *)key parameters:(NSDictionary*)parameters;

// Record event in given categories with given additional parameters.
- (void)recordEvent:(NSString *)key category:(NSString*)category parameters:(NSDictionary*)parameters;
- (void)recordEvent:(NSString *)key categories:(NSArray*)categories parameters:(NSDictionary*)parameters;

// Get the session time for this Lytics object.
- (NSNumber*)sessionTime;

@end


