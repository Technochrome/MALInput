//
//  MALHid.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

static void deviceConnection(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	NSString * desc = [[MALHidCenter shared] descriptionForPage:usagePage usage:usageID];
	
	printf("Connect: %x %s #%x_%x\n",location, [desc UTF8String], usagePage, usageID);
	
	if(usageID == kHIDUsage_GD_Keyboard) return;
	if(location == 0) return;
	
	for(id _element in (NSArray*)IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone)) {
		IOHIDElementRef element = (IOHIDElementRef)_element;
		if(!IOHIDElementIsArray(element))
			[[MALHidElement alloc] initWithElement:(IOHIDElementRef)element namespace:desc];
	}
}


static void deviceRemoval(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	printf("Disconnect: %x %s #%x_%x\n",location, [[[MALHidCenter shared] descriptionForPage:usagePage usage:usageID] UTF8String], usagePage, usageID);
}

static void deviceInput(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDValueRef newValue) {
	return;
	
	IOHIDElementRef element = IOHIDValueGetElement(newValue);
	int eUsagePage = IOHIDElementGetUsagePage(element);
	int eUsageID = IOHIDElementGetUsage(element);
	
	NSString * key = [MALHidElement keyForElement:element];
	
	printf("%s - %s = %lx\n",
		   [key UTF8String],
		   [[[MALHidCenter shared] descriptionForPage:eUsagePage usage:eUsageID] UTF8String],
		   IOHIDValueGetIntegerValue(newValue));
}

void getDevices() {
	IOHIDManagerRef io = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
	
	// make an array of matching dictionaries for the HIDManager
	int matches[] = {kHIDUsage_GD_Mouse, kHIDUsage_GD_Keyboard, kHIDUsage_GD_Pointer, kHIDUsage_GD_Joystick, kHIDUsage_GD_GamePad};
	NSMutableArray * matchingValues = [NSMutableArray array];
	
	for(int i=0; i<sizeArr(matches); i++) {
		[matchingValues addObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  [NSNumber numberWithInt:kHIDPage_GenericDesktop], [NSString stringWithUTF8String:kIOHIDDeviceUsagePageKey],
		  [NSNumber numberWithInt:matches[i]], [NSString stringWithUTF8String:kIOHIDDeviceUsageKey],
		  nil]];
	}
	
	IOHIDManagerSetDeviceMatchingMultiple(io, (CFMutableArrayRef)matchingValues);
	
	// Set Callback Routines
	IOHIDManagerRegisterDeviceMatchingCallback(io, deviceConnection, NULL);
	IOHIDManagerRegisterDeviceRemovalCallback(io, deviceRemoval, NULL);
	IOHIDManagerRegisterInputValueCallback(io, deviceInput, NULL);
	
	IOHIDManagerScheduleWithRunLoop(io, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	
	// Opens all current and future devices for communication
	IOHIDManagerOpen(io, kIOHIDManagerOptionNone);
	
	CFRetain(io);
}