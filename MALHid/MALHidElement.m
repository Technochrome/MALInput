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
-(int) cookie { return IOHIDElementGetCookie(element); }
-(NSString*) key { return [MALHidElement keyForElement:element]; }

#pragma mark new/delete
+(NSString*) keyForElement:(IOHIDElementRef)element {
	IOHIDDeviceRef device = IOHIDElementGetDevice(element);
	
	int cookie = IOHIDElementGetCookie(element);
	
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
	return [[MALHidCenter shared] descriptionForPage:hidUsage.page
											   usage:hidUsage.ID];
}
-(id) initWithElement:(IOHIDElementRef) e namespace:(NSString*)ns {
	self = [super init];
	if(!self) return nil;
	
	element = e;
	hidUsage = MakeMALHidUsage(IOHIDElementGetUsagePage(element), IOHIDElementGetUsage(element));
	if(hidUsage.ID == 0xffffffff) { // Unknown Usage
		[self release]; return nil;
	}
	
	isRelative = IOHIDElementIsRelative(element);
	isWrapping = IOHIDElementIsWrapping(element);
	max = IOHIDElementGetLogicalMax(element);
	min = IOHIDElementGetLogicalMin(element);
	
	NSString * desc = [[MALHidCenter shared] descriptionForPage:hidUsage.page usage:hidUsage.ID];
	ns = [NSString stringWithFormat:@"%@.%@", ns, desc];
	
	if(![desc hasPrefix:@"Unknown"]) {
//		[[MALHidCenter shared] addObserver:self forElement:element];
		
//		printf(" %s (%u) #%x_%x {%d %d} [%ld %ld]\n",
//			   [ns UTF8String],IOHIDElementGetCookie(element),
//			   usagePage, usageID,
//			   rel, wrap,
//			   min, max);
	} else {
		[self release];
		return nil;
	}
	
	return self;
}
+(id) hidElementWithElement:(IOHIDElementRef)e {
	MALHidElement * element = [[[self alloc] initWithElement:e namespace:nil] autorelease];
	
	if([[MALHidCenter shared] addObserver:element forElement:e]) {
		
		[element setPath:[MALHidElement keyForElement:e]];
		return element;
	} else return nil;
}

-(void) valueChanged:(IOHIDValueRef)newValue {
	[self updateValue:IOHIDValueGetIntegerValue(newValue) timestamp:IOHIDValueGetTimeStamp(newValue)];
}
@end