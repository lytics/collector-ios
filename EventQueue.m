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

#import "EventQueue.h"
#import "Event.h"

@implementation EventQueue

- (id)init
{
    if (self = [super init])
    {
        events_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [events_ release];
    [super dealloc];
}

- (NSUInteger)count
{
    @synchronized (self)
    {
        return [events_ count];
    }
}

- (NSArray *)events
{
    NSArray *result = nil;
    
    @synchronized (self)
    {
        result = [[events_ retain] autorelease];
		
        [events_ release];
        events_ = [[NSMutableArray alloc] init];
    }
	
	return result;
}

- (void)recordEvent:(NSString *)key
{
    @synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		[event processCategories];
//        event.count = 1;
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}

- (void)recordEvent:(NSString *)key category:(NSString *)category
{
    @synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		event.categories = [NSArray arrayWithObject:category];
		[event processCategories];
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}

- (void)recordEvent:(NSString *)key categories:(NSArray *)categories
{
    @synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		event.categories = categories;
		[event processCategories];
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}


- (void)recordEvent:(NSString *)key parameters:(NSDictionary *)parameters
{
    @synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		[event addParametersFromDictionary:parameters];
		[event processCategories];
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}

- (void)recordEvent:(NSString *)key category:(NSString *)category parameters:(NSDictionary *)parameters
{
    @synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		event.categories = [NSArray arrayWithObject:category];
		[event addParametersFromDictionary:parameters];
		[event processCategories];
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}

- (void)recordEvent:(NSString*)key categories:(NSArray *)categories parameters:(NSDictionary *)parameters
{
	@synchronized (self)
    {
        Event *event = [[Event alloc] init];
        event.key = key;
		event.categories = categories;
		[event addParametersFromDictionary:parameters];
		[event processCategories];
//        event.timestamp = time(NULL);
        [events_ addObject:event];
		[event release];
    }
}

@end
