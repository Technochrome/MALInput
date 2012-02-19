//
//  MALHid.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

static NSDictionary * usageTables = nil;
static NSMutableSet * connectedDevices = nil;
static NSDictionary * deviceNamespaces = nil;

static void deviceConnection(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int product = [getHIDDeviceProperty(device, kIOHIDProductIDKey) intValue];
	int vendor = [getHIDDeviceProperty(device, kIOHIDVendorIDKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	//check to see if device type is known
	NSString * ns = nil;
	NSDictionary * pageTable = [deviceNamespaces objectForKey:[NSString stringWithFormat:@"%d",usagePage]];
	if(pageTable) {
		ns = [pageTable objectForKey:[NSString stringWithFormat:@"%d",usageID]];
		if(!ns) {
			NSString * defaultFormat = [pageTable objectForKey:@"default"];
			if(defaultFormat) ns = [NSString stringWithFormat:defaultFormat, usageID];
		}
	} else {
		NSString * defaultFormat = [deviceNamespaces objectForKey:@"default"];
		if(defaultFormat) ns = [NSString stringWithFormat:defaultFormat, usagePage, usageID];
	}
	printf("Connection: %x %s #%x_%x {%x %x}",location, [ns UTF8String], usagePage, usageID, vendor, product);
	
	// Things that will disqualify a device
	if([ns isEqualToString:@"SKIP"] || location == 0) goto DeviceConnectionDenied;
	
	// NO DUPLICATES
	NSString * deviceName = [NSString stringWithFormat:@"%x.%x.%x", location, usagePage, usageID];
	if([connectedDevices member:deviceName]) goto DeviceConnectionDenied;
	[connectedDevices addObject:deviceName];
	
	if(NO) {
		DeviceConnectionDenied: printf(" ... Denied\n"); return;
	}
	
	printf(" ... Accepted\n");
	
	for(id _element in (NSArray*)IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone)) {
		IOHIDElementRef element = (IOHIDElementRef)_element;
		if(!IOHIDElementIsArray(element)) {
			MALHidElement * e = [MALHidElement hidElementWithElement:element];
//			MALHidElement * e = [[MALHidElement alloc] initWithElement:(IOHIDElementRef)element namespace:ns];
			// add to non-raw tree
			// add derivative elements
		}
	}
	
}


static void deviceRemoval(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	NSString * desc = [[MALHidCenter shared] descriptionForPage:usagePage usage:usageID];
	
	printf("Disconnect: %x %s #%x_%x\n",location, [desc UTF8String], usagePage, usageID);
	
	[connectedDevices removeObject:[NSString stringWithFormat:@"%x.%x.%x", location, usagePage, usageID]];
}

static void deviceInput(void * context, IOReturn inResult, void * HIDManagerRef, IOHIDValueRef newValue) {
	[[MALHidCenter shared] newValue:newValue];
}

void startMALHidListener() {
	
	// This data controls how devices and elements are handled
	NSBundle * myBundle = [NSBundle bundleForClass:[MALHidCenter class]];
	NSString * usageTablesPath = [myBundle pathForResource: @"MALHidUsageMap" ofType: @"plist"];
	usageTables = [[NSDictionary dictionaryWithContentsOfFile: usageTablesPath] retain];
	deviceNamespaces = [usageTables objectForKey:@"DeviceNamespace"];
	connectedDevices = [[NSMutableSet alloc] init];
	
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