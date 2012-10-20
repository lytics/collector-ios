//
//  LyticsSettings.h
//
//  Created by Mathew Polzin on 10/17/12.
//

#import <Foundation/Foundation.h>

// Settings are stored in a singleton class
@interface LyticsSettings : NSObject
{
	NSDictionary* settings;
	NSMutableDictionary* globalParameterGetters;
}

@property (atomic, readonly) NSDictionary* settings;
@property (atomic, readonly) NSMutableDictionary* globalParameterGetters;

// Get the value of a settings stored in the general_settings section of
// LyticsSettings.plist
+ (id)generalSetting:(NSString*)settingName;

// Get all global keys and their assosciated parameter names. Global parameters
// are those that are not event-dependent. They will be determined when an
// event is sent using the assosciated accessor set with setAccessorForGlobalKey
// method.
+ (NSDictionary*)globalKeys;

// Get all local keys and their assosciated parameter names. Local parameters
// are event-dependent so they must be passed as parameters to each recordEvent
// call.
+ (NSDictionary*)localKeys;

// Get the parameter name for a given parameter key.
+ (NSString*)parameterNameForKey:(NSString*)key;

// Get all event categories and the assosciated arrays of parameter keys. An
// event category groups global parameter keys so that when an event is given
// that category the parameters in the category are automatically attached to
// that event.
+ (NSDictionary*)categories;

// Get the parameter keys in a given event category.
+ (NSArray*)keysInCategory:(NSString*)category;

// Get an array of the keys for built-in events that are automatically generated
+ (NSArray*)defaultEventKeys;

// Get an event name for a given event key.
+ (NSString*)eventNameForKey:(NSString*)key;

// Set an accessor method for a given global parameter key. When an event
// includes a global parameter, the method assosciated with that parameter's key
// will be invoked to get the parameter value.
+ (void)setAccessorForGlobalKey:(NSString*)key target:(id)target selector:(SEL)getter;

// Get the global parameter value for the given key. If the given key does not
// have an accessor assosciated with it yet (using setAccessorForGlobalKey)
// then an exception is raised.
+ (id)getParameterValueForGlobalKey:(NSString*)key;

// Load the settings from LyticsSettings.plist. This method is invoked
// automatically upon the first request to any of the LyticsSettings class
// methods. It can still be manually invoked (perhaps to save a very slight
// amount of time) at any point before any other LyticsSettings methods are
// called upon.
+ (void)loadSettings;

@end
