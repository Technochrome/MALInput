//
//  MALHid.c
//  MALHid
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

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
	int version = [getHIDDeviceProperty(device, kIOHIDVersionNumberKey) intValue];
	
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
	NSLog(@"Input Device connection :: %x.%x (%s) {%x.%x}", usagePage, usageID, [ns UTF8String], location, version);
	
	// Things that will disqualify a device
	if([ns isEqualToString:@"SKIP"] || location == 0) return;
	
	for(id element in (NSArray*)IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone)) {
		IOHIDElementType type = IOHIDElementGetType((IOHIDElementRef)element);
		if(type == kIOHIDElementTypeCollection || type == kIOHIDElementTypeFeature) continue;
		
		[MALHidElement hidElementWithElement:(IOHIDElementRef)element];
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
	int matches[] = {kHIDUsage_GD_Mouse, kHIDUsage_GD_Keyboard, kHIDUsage_GD_Keypad, kHIDUsage_GD_Pointer, kHIDUsage_GD_Joystick, kHIDUsage_GD_GamePad};
	NSMutableArray * matchingValues = [NSMutableArray array];
	
	for(int i=0; i<sizeArr(matches); i++) {
		[matchingValues addObject:@{@(kIOHIDDeviceUsagePageKey):@(kHIDPage_GenericDesktop), @(kIOHIDDeviceUsageKey):@(matches[i])}];
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

#pragma mark Implementations
@implementation MALHidCenter
+(void) load {
	[self shared];
}
+(MALHidCenter *) shared {
	static MALHidCenter * shared = nil;
	if(!shared) {
		shared = [[self alloc] _init];
		startMALHidListener();
	}
	return shared;
}
-(BOOL) addObserver:(MALHidElement*)o forElement:(IOHIDElementRef)e {
	if(!o) return NO;
	NSString * key = [MALHidElement keyForElement:e];
	if([rawValueDict objectForKey:key]) return NO;
	[rawValueDict setObject:o forKey:key];
	return YES;
}
-(void) removeObserver:(MALHidElement*)o {
	for(id key in [rawValueDict allKeysForObject:o])
		[rawValueDict removeObjectForKey:key];
}
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usage {

	static NSString * usageFmt = @"0x%04X";
	NSString * usagePageString = [NSString stringWithFormat: usageFmt, usagePage];
	NSString * usageString = [NSString stringWithFormat: usageFmt, usage];

	NSDictionary * usagePageLookup = [mLookupTables objectForKey: usagePageString];
	if (usagePageLookup == nil)
		return [NSString stringWithFormat:@"Unknown usage page %@,%@",usagePageString,usageString];

	NSString * description = [usagePageLookup objectForKey: usageString];
	if (description != nil)
		return description;

	// Buttons for instance don't have descriptions for each ID, default = @"button %d"
	NSString * defaultUsage = [usagePageLookup objectForKey: @"default"];
	if (defaultUsage != nil) {
		description = [NSString stringWithFormat: defaultUsage, usage];
		return description;
	}

	return @"Unknown usage";
}
-(id) _init {
	self = [super init]; if(!self) return nil;
	
	NSBundle * myBundle = [NSBundle bundleForClass:[MALHidCenter class]];
	NSString * usageTablesPath = [myBundle pathForResource: @"HID_usage_strings" ofType: @"plist"];
	mLookupTables = [[NSDictionary dictionaryWithContentsOfFile: usageTablesPath] retain];
	
	rawValueDict = [[NSMutableDictionary alloc] init];
	
	return self;
}
-(id) init {
	@throw [NSException exceptionWithName:@"Don't call [[MALHidCenter alloc] init]"
								   reason:@"Use [MALHidCenter shared] instead."
								 userInfo:nil];
}

-(void) newValue:(IOHIDValueRef)value {
	NSString * key = [MALHidElement keyForElement:IOHIDValueGetElement(value)];
	MALHidElement * ob = [rawValueDict objectForKey:key];
	[ob valueChanged:value];
}
@end