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

#import "Event.h"
#import "LyticsSettings.h"

@implementation Event

@synthesize key = key_;
@synthesize parameters = parameters_;
@synthesize categories = categories_;
//@synthesize count = count_;
//@synthesize sum = sum_;
//@synthesize timestamp = timestamp_;

- (id)init
{
    if (self = [super init])
    {
        key_ = nil;
        parameters_ = nil;
		categories_ = nil;
//        count_ = 0;
//        sum_ = 0;
//        timestamp_ = 0;
    }
    return self;
}

// This allows Event objects to be turned into JSON strings or data by the
// JSONKit library.
- (id)dictionaryOrArrayRepresentation
{
	// For an event, we will return a dictionary representation.
	NSMutableDictionary* dict = [[[NSMutableDictionary alloc] initWithCapacity:8] autorelease];
	
	// Always include the event name if available
	if (self.key) {
		[dict setObject:[LyticsSettings eventNameForKey:self.key] forKey:[LyticsSettings parameterNameForKey:@"EVENT_NAME_KEY"]];
	}
	
	if (!categoriesProcessed) {
		[self processCategories];
	}
	
	if (parameters_ != nil) {
		[dict addEntriesFromDictionary:parameters_];
	}
	
	return dict;
}

// Use the JSONKit library to turn this Event into JSON data.
- (NSData*)JSONData
{
	return [[self dictionaryOrArrayRepresentation] JSONData];
}

// Use the JSONKit library to turn this Event into a JSON string.
- (NSString*)JSONString
{
	return [[self dictionaryOrArrayRepresentation] JSONString];
}

- (void)processCategories
{
	categoriesProcessed = YES;
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:8];
	
	//always add parameters in the "all" category
	for (NSString* key in [LyticsSettings keysInCategory:@"all"]) {
		[dict setObject:[LyticsSettings getParameterValueForGlobalKey:key] forKey:[LyticsSettings parameterNameForKey:key]];
	}
	
	if (categories_ != nil) {
		for (NSString* category in categories_) {
			for (NSString* key in [LyticsSettings keysInCategory:category]) {
				[dict setObject:[LyticsSettings getParameterValueForGlobalKey:key] forKey:[LyticsSettings parameterNameForKey:key]];
			}
		}
	}
	
	if ([dict count] > 0) {
		if (self.parameters) {
			[self.parameters addEntriesFromDictionary:dict];
		} else {
			self.parameters = dict;
		}
	}
}

- (void)addParametersFromDictionary:(NSDictionary*)dict
{
	if (self.parameters) {
		[self.parameters addEntriesFromDictionary:dict];
	} else {
		self.parameters = [[dict mutableCopy] autorelease];
	}
}

// Output something useful when printing to the log.
- (NSString*)description
{
	return [[self dictionaryOrArrayRepresentation] description];
}

- (void)dealloc
{
    [key_ release];
    [parameters_ release];
	[categories_ release];
    [super dealloc];
}

@end
