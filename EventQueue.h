//
// EventQueue.h
//
// Code based on Countly SDK source: https://github.com/Countly/countly-sdk-ios
//
// Modified by Mathew Polzin, Vadio Inc.
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import <Foundation/Foundation.h>

@interface EventQueue : NSObject
{
    NSMutableArray *events_;
}

// Accessors:
- (NSUInteger)count;
- (NSArray *)events;

// Add an event to the queue:
- (void)recordEvent:(NSString *)key;
- (void)recordEvent:(NSString *)key category:(NSString *)category;
- (void)recordEvent:(NSString *)key categories:(NSArray *)categories;
- (void)recordEvent:(NSString *)key parameters:(NSDictionary *)parameters;
- (void)recordEvent:(NSString *)key category:(NSString *)category parameters:(NSDictionary *)parameters;
- (void)recordEvent:(NSString*)key categories:(NSArray *)categories parameters:(NSDictionary *)parameters;
@end
