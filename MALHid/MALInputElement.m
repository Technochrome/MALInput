//
//  MALInputElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALInputPrivate.h"

@implementation MALInputElement
@synthesize usage=hidUsage,elementID;

-(id) init {
	if((self = [super init])) {
		isDiscoverable = YES;
		
		isRelative = NO;
		isWrapping = NO;
		rawMax = 1;
		rawMin = 0;
	} return self;
}
-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	[super updateValue:newValue timestamp:t];
	if(isDiscoverable && timestamp == t) [[MALInputCenter shared] valueChanged:self];
}
-(NSString*) fullID {
	return [NSString stringWithFormat:@"%@~%@", generalDevice.deviceID, self.elementID];
}
-(NSString*) specificPath {
	return [NSString stringWithFormat:@"%@~%@", specificDevice.devicePath, self.elementID];
}
-(NSString*) generalPath {
	return [NSString stringWithFormat:@"%@~%@", generalDevice.devicePath, self.elementID];
}
+(NSString*) deviceIDFromFullID:(NSString*)fullID {
	return [fullID componentsSeparatedByString:@"~"][0];
}
+(NSString*) elementIDFromFullID:(NSString*)fullID {
	return [fullID componentsSeparatedByString:@"~"][1];
}
@end

@implementation MALInputElement (HID)
#pragma mark accessors

+(MALHidUsage) usageForElement:(IOHIDElementRef)e {
	return MakeMALHidUsage(IOHIDElementGetUsagePage(e), IOHIDElementGetUsage(e));
}
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

#pragma mark new/delete
-(MALInputElement*) initWithHIDElement:(IOHIDElementRef)element {
	if(!(self = [super init])) return nil;
	
	hidUsage = MakeMALHidUsage(IOHIDElementGetUsagePage(element), IOHIDElementGetUsage(element));
	
	isRelative = IOHIDElementIsRelative(element);
	isWrapping = IOHIDElementIsWrapping(element);
	rawMax = IOHIDElementGetLogicalMax(element);
	rawMin = IOHIDElementGetLogicalMin(element);
	
	isDiscoverable = YES;
	self.elementID = [[MALHidCenter shared] descriptionForElement:element];
	
	[[MALHidCenter shared] addObserver:self forHIDElement:element];
	
	return self;
}
+(MALInputElement*) elementWithHIDElement:(IOHIDElementRef)e {
	return [[[self alloc] initWithHIDElement:e] autorelease];
}
+(MALInputElement*) element {
	return [[[self alloc] init] autorelease];
}

-(void) valueChanged:(IOHIDValueRef)newValue {
	[self updateValue:IOHIDValueGetIntegerValue(newValue) timestamp:IOHIDValueGetTimeStamp(newValue)];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"<%@: %@>",[self class],self.fullID];
}

-(void) dealloc {
	[[MALHidCenter shared] removeObserver:self];
	[super dealloc];
}
@end