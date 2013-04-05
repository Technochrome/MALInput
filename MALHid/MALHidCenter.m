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

#pragma mark Implementations
@implementation MALHidCenter
+(MALHidCenter *) shared {
	static MALHidCenter * shared = nil;
	if(!shared) {
		shared = [[self alloc] _init];
	}
	return shared;
}

-(void) deviceInput:(IOHIDValueRef)value {
	IOHIDElementRef element = IOHIDValueGetElement(value);
	MALHidElement * obj = [hidElements objectForKey:[MALHidElement keyForElement:element]];
	[obj valueChanged:value];
}
-(void) deviceRemoval:(IOHIDDeviceRef)device {
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	NSString * desc = [[MALHidCenter shared] descriptionForPage:usagePage usage:usageID];
	
	printf("Disconnect: %x %s #%x_%x\n",location, [desc UTF8String], usagePage, usageID);
	
	[connectedDevices removeObject:[NSString stringWithFormat:@"%x.%x.%x", location, usagePage, usageID]];
}
-(void) deviceConnection:(IOHIDDeviceRef)deviceRef {
	NSString * deviceID = [self descriptionForDevice:deviceRef];
	if(!deviceID) return;
	
	// Get/Make the aliases that this device matches
	MALIODevice * deviceGeneral = [[MALInputCenter shared] deviceAtPath:deviceID];
	if(!deviceGeneral) {
		deviceGeneral = [MALIODevice device];
		deviceGeneral.deviceID = deviceID;
		deviceGeneral.location = 0;
		[[MALInputCenter shared] addDevice:deviceGeneral atPath:deviceID];
	}
	deviceGeneral.location = [getHIDDeviceProperty(deviceRef, kIOHIDLocationIDKey) intValue];
	MALIODevice * deviceSpecific = [[MALInputCenter shared] deviceAtPath:deviceGeneral.devicePath];
	if(!deviceSpecific) {
		deviceSpecific = [MALIODevice device];
		deviceSpecific.deviceID = deviceID;
		deviceSpecific.location = deviceGeneral.location;
		[[MALInputCenter shared] addDevice:deviceSpecific atPath:deviceSpecific.devicePath];
	}
	deviceGeneral.location = 0;
	
	
	// Check which elements should be added to the device
	NSArray * elements = [(NSArray*)IOHIDDeviceCopyMatchingElements(deviceRef, NULL, kIOHIDOptionsTypeNone) autorelease];
	for(id _element in elements) {
		IOHIDElementRef element = (IOHIDElementRef)_element;
		
		MALHidUsage hidUsage = [MALHidElement usageForElement:element];
		if([[[MALHidCenter shared] descriptionForPage:hidUsage.page usage:hidUsage.ID] hasPrefix:@"Unknown"])
			continue;
		
		//Only want end elements
		IOHIDElementType type = IOHIDElementGetType(element);
		if(type == kIOHIDElementTypeCollection || type == kIOHIDElementTypeFeature) continue;
		
		for(MALElementConnectionObserver modifier in elementConnectionObservers) {
			id newElements = modifier(element);
			
			[deviceSpecific.elements addEntriesFromDictionary:newElements];
		}
	}
	
	NSLog(@"Input Device connection :: %@ %@", deviceSpecific.devicePath, deviceSpecific.elements);
}

static void deviceInput(void * inputCenter, IOReturn inResult, void * HIDManagerRef, IOHIDValueRef newValue) {
	[(MALHidCenter*)inputCenter deviceInput:newValue];
}
static void deviceRemoval(void * inputCenter, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	[(MALHidCenter*)inputCenter deviceRemoval:device];
}
static void deviceConnection(void * inputCenter, IOReturn inResult, void * HIDManagerRef, IOHIDDeviceRef device) {
	[(MALHidCenter*)inputCenter deviceConnection:device];
}

-(void) startListening {
	if(isListening) return;
	isListening = YES;
	
	// make an array of matching dictionaries for the HIDManager
	int matches[] = {kHIDUsage_GD_Mouse, kHIDUsage_GD_Keyboard, kHIDUsage_GD_Keypad, kHIDUsage_GD_Pointer, kHIDUsage_GD_Joystick, kHIDUsage_GD_GamePad};
	NSMutableArray * matchingValues = [NSMutableArray array];
	
	for(int i=0; i<sizeArr(matches); i++) {
		[matchingValues addObject:@{@(kIOHIDDeviceUsagePageKey):@(kHIDPage_GenericDesktop), @(kIOHIDDeviceUsageKey):@(matches[i])}];
	}
	
	IOHIDManagerSetDeviceMatchingMultiple(ioManager, (CFMutableArrayRef)matchingValues);
	IOHIDManagerRegisterDeviceMatchingCallback(ioManager, deviceConnection, self);
	IOHIDManagerRegisterDeviceRemovalCallback(ioManager, deviceRemoval, self);
	IOHIDManagerRegisterInputValueCallback(ioManager, deviceInput, self);
	IOHIDManagerScheduleWithRunLoop(ioManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	
	// Opens all current and future devices for communication
	IOHIDManagerOpen(ioManager, kIOHIDManagerOptionNone);
}

-(void) addElementConnectionObserver:(MALElementConnectionObserver)modifier {
	[elementConnectionObservers insertObject:modifier atIndex:0];
}
-(BOOL) addObserver:(MALHidElement*)o forElement:(IOHIDElementRef)e {
	if(!o) return NO;
	id key = [NSValue valueWithPointer:e];
	if([hidElements objectForKey:key]) return NO;
	[hidElements setObject:o forKey:key];
	return YES;
}
-(void) removeObserver:(MALHidElement*)o {
	for(id key in [hidElements allKeysForObject:o])
		[hidElements removeObjectForKey:key];
}
-(NSString *) descriptionForDevice:(IOHIDDeviceRef)device {
	MALHidUsage usage = [MALIODevice usageForDevice:device];
	
	NSDictionary * generalDescriptions = [usageTables objectForKey:@"DeviceIdentifier"];
	NSString * format = [generalDescriptions objectForKey:[NSString stringWithFormat:@"%d.%d",usage.page,usage.ID]];
	
	return [NSString stringWithFormat:format,
			[getHIDDeviceProperty(device, kIOHIDVendorIDKey) intValue],
			[getHIDDeviceProperty(device, kIOHIDProductIDKey) intValue],
			[getHIDDeviceProperty(device, kIOHIDVersionNumberKey) intValue]];
}
-(NSString *) descriptionForElement:(IOHIDElementRef)element {
	MALHidUsage usage = [MALHidElement usageForElement:element];
	NSString * deviceID = [self descriptionForDevice:IOHIDElementGetDevice(element)];
	
	NSDictionary * elementDescriptions = usageTables[@"ElementIdentifier"][deviceID];
	if(elementDescriptions) {
		NSString * desc = elementDescriptions[[NSString stringWithFormat:@"%x.%x", usage.page, usage.ID]];
		if(desc) return desc;
	}
	
	return [self descriptionForPage:usage.page usage:usage.ID];
}
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usageID {

	static NSString * usageFmt = @"0x%04X";
	NSString * usagePageString = [NSString stringWithFormat: usageFmt, usagePage];
	NSString * usageString = [NSString stringWithFormat: usageFmt, usageID];

	NSDictionary * usagePageLookup = [mLookupTables objectForKey: usagePageString];
	if (usagePageLookup == nil)
		return [NSString stringWithFormat:@"Unknown usage page %@,%@",usagePageString,usageString];

	NSString * description = [usagePageLookup objectForKey: usageString];
	if (description != nil)
		return description;

	// For instance, buttons don't have descriptions for each ID, so we use default = @"button %d"
	NSString * defaultUsage = [usagePageLookup objectForKey: @"default"];
	if (defaultUsage != nil) {
		description = [NSString stringWithFormat: defaultUsage, usageID];
		return description;
	}

	return @"Unknown usage";
}
-(id) _init {
	if((self = [super init])) {
		isListening = NO;
		
		NSBundle * myBundle = [NSBundle bundleForClass:[self class]];
		NSString * usageDescriptionsPath = [myBundle pathForResource: @"HID_usage_strings" ofType: @"plist"];
		mLookupTables = [[NSDictionary dictionaryWithContentsOfFile: usageDescriptionsPath] retain];
		
		// This data controls how devices and elements are handled
		NSString * usageTablesPath = [myBundle pathForResource: @"MALHidUsageMap" ofType: @"plist"];
		usageTables = [[NSDictionary dictionaryWithContentsOfFile: usageTablesPath] retain];
		deviceNamespaces = [usageTables objectForKey:@"DeviceNamespace"];
		connectedDevices = [[NSMutableSet alloc] init];
		
		hidElements = [[NSMutableDictionary alloc] init];
		devices = [[NSMutableDictionary alloc] init];
		elementConnectionObservers = [[NSMutableArray alloc] init];
		[self addElementConnectionObserver:^NSDictionary*(IOHIDElementRef element) {
			MALHidElement * e = [MALHidElement hidElementWithElement:element];
			return @{[[MALHidCenter shared] descriptionForElement:element]: e};
		}];
		
		ioManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
		CFRetain(ioManager);
	}
	return self;
}
-(id) init {
	@throw [NSException exceptionWithName:@"Don't call [[MALHidCenter alloc] init]"
								   reason:@"Use [MALHidCenter shared] instead."
								 userInfo:nil];
}
@end