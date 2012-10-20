//
// Event.h
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import <Foundation/Foundation.h>
#import "JSONKit.h"

// Events are the smallest unit of analytics data.
@interface Event : NSObject <JSONReady>
{
	BOOL categoriesProcessed;
}

// The event key names the event.
@property (nonatomic, copy) NSString *key;

// Optional. If set, then all global parameters in the given
// category (see LyticsSettings.plist) are sent with this event.
@property (nonatomic, retain) NSArray *categories;

// Optional. If set, then the key/value pairs in this dictionary are sent with
// this event in addition to any parameters in the categories this event
// belongs to.
@property (nonatomic, retain) NSMutableDictionary *parameters;

//@property (nonatomic, assign) int count;
//@property (nonatomic, assign) double sum;
//@property (nonatomic, assign) double timestamp;

// Use the JSONKit library to turn this Event into JSON data.
- (NSData*)JSONData;

// Use the JSONKit library to turn this Event into a JSON string.
- (NSString*)JSONString;

// This method adds parameters for each category the event is in. Usually, the
// desired result is obtained by calling this at the time the event is created.
// If this has not been called by the time the event is sent, it is called at
// that time.
- (void)processCategories;

- (void)addParametersFromDictionary:(NSDictionary*)dict;

@end