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
	NSLog(@"Input Device connection :: #%x_%x (%s) {%x}", usagePage, usageID, [ns UTF8String], location);
	
	// Things that will disqualify a device
	if([ns isEqualToString:@"SKIP"] || location == 0) return;
	
	// NO DUPLICATES
//	NSString * deviceName = [NSString stringWithFormat:@"%x.%x.%x", location, usagePage, usageID];
//	if([connectedDevices member:deviceName]) return;
//	[connectedDevices addObject:deviceName];
	
	
	for(id element in (NSArray*)IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone)) {
		IOHIDElementType type = IOHIDElementGetType((IOHIDElementRef)element);
		if(type == kIOHIDElementTypeCollection || type == kIOHIDElementTypeFeature) continue;
		
		MALHidElement * e = [MALHidElement hidElementWithElement:(IOHIDElementRef)element];
		if(!e) continue;
		
		MALHidUsage usage = [e usage];
		if(usage.page == 0 && usage.ID == 0)
			printf("---------------------\n");
		NSLog(@"Added Element %@ (%@)",e,[e path]);
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
		  @(kHIDPage_GenericDesktop), [NSString stringWithUTF8String:kIOHIDDeviceUsagePageKey],
		  @(matches[i]), [NSString stringWithUTF8String:kIOHIDDeviceUsageKey],
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