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

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
{
}

// Access given information about the device:
+ (NSString *)device;
+ (NSString *)osVersion;
+ (NSString*)os;
+ (NSString *)carrier;
+ (id)carrierOrNULL;
+ (NSString *)resolution;
+ (NSString *)locale;
+ (NSString *)appVersion;
+ (NSNumber *)timestamp; //unix timestamp

// Return a JSON string containing all device metrics above.
+ (NSString *)metrics;

// Register each of the above metric methods with the LyticsSettings class as
// global parameter accessors.
+ (void)registerGlobalAccessors;
@end
