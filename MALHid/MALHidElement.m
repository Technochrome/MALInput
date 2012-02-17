//
//  MALHidElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidElement.h"

@implementation MALHidElement
#pragma mark accessors
-(IOHIDDeviceRef) device { return IOHIDElementGetDevice(element); }
-(int) cookie { return IOHIDElementGetCookie(element); }
-(MALHidUsage) usage { return MakeMALHidUsage(IOHIDElementGetUsagePage(element), IOHIDElementGetUsage(element)); }

#pragma mark new/delete
+(NSString*) keyForElement:(IOHIDElementRef)element {
	IOHIDDeviceRef device = IOHIDElementGetDevice(element);
	
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	int cookie = IOHIDElementGetCookie(element);
	
	NSString * key = [NSString stringWithFormat:@"%x.%x.%x.%x", location, usagePage, usageID, cookie];
	
	return key;
}
-(id) initWithElement:(IOHIDElementRef) e namespace:(NSString*)ns {
	self = [super init];
	if(!self) return nil;
	
	element = e;
	
	unsigned usageID = IOHIDElementGetUsage(element);
	unsigned usagePage = IOHIDElementGetUsagePage(element);
	bool rel = IOHIDElementIsRelative(element);
	bool wrap = IOHIDElementIsWrapping(element);
	CFIndex maxv = IOHIDElementGetLogicalMax(element);
	CFIndex minv = IOHIDElementGetLogicalMin(element);
	NSString * desc = [[MALHidCenter shared] descriptionForPage:usagePage usage:usageID];
	ns = [NSString stringWithFormat:@"%@.%@", ns, desc];
	
	if(![desc hasPrefix:@"Unknown"]) {
		[[MALHidCenter shared] addObserver:self forElement:element];
		
		printf(" %s (%u) #%x_%x {%d %d} [%ld %ld]\n",
			   [ns UTF8String],IOHIDElementGetCookie(element),
			   usagePage, usageID,
			   rel, wrap,
			   minv, maxv);
	} else {
		[self release];
		return nil;
	}
	
	return self;
}
@end