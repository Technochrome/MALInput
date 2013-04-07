//
//  MALHidElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@implementation MALHidElement
#pragma mark accessors
-(IOHIDDeviceRef) device { return IOHIDElementGetDevice(element); }
-(int) cookie { return (int)IOHIDElementGetCookie(element); }


+(MALHidUsage) usageForElement:(IOHIDElementRef)e {
	return MakeMALHidUsage(IOHIDElementGetUsagePage(e), IOHIDElementGetUsage(e));
}

#pragma mark new/delete
+(NSValue*) keyForElement:(IOHIDElementRef)element {
	return [NSValue valueWithPointer:element];
}
+(NSString*) pathForElement:(IOHIDElementRef)element {
	IOHIDDeviceRef device = IOHIDElementGetDevice(element);
	
	int cookie = (int)IOHIDElementGetCookie(element);
	
	NSMutableString * key = [NSMutableString stringWithFormat:@"%x",cookie];
	for (IOHIDElementRef e = element; (e = IOHIDElementGetParent(e));) {
		[key appendFormat:@"(%x.%x)",IOHIDElementGetUsagePage(e),IOHIDElementGetUsage(e)];
	}
	[key appendFormat:@"%x.%x",
	 [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue],
	 [getHIDDeviceProperty(device, kIOHIDVersionNumberKey) intValue]];
	
	return key;
}
-(NSString*) description {
	return self.fullID;
}
-(id) initWithElement:(IOHIDElementRef)e {
	if(!(self = [super init])) return nil;
	
	element = e;
	hidUsage = MakeMALHidUsage(IOHIDElementGetUsagePage(element), IOHIDElementGetUsage(element));
	
	isRelative = IOHIDElementIsRelative(element);
	isWrapping = IOHIDElementIsWrapping(element);
	rawMax = IOHIDElementGetLogicalMax(element);
	rawMin = IOHIDElementGetLogicalMin(element);
	
	isDiscoverable = YES;
	self.elementID = [[MALHidCenter shared] descriptionForElement:element];
	
	[[MALHidCenter shared] addObserver:self forElement:element];
	
	return self;
}
+(id) hidElementWithElement:(IOHIDElementRef)e {
	return [[[self alloc] initWithElement:e] autorelease];
}

-(void) valueChanged:(IOHIDValueRef)newValue {
	[self updateValue:IOHIDValueGetIntegerValue(newValue) timestamp:IOHIDValueGetTimeStamp(newValue)];
}

-(void) dealloc {
	[[MALHidCenter shared] removeObserver:self];
	[super dealloc];
}
@end