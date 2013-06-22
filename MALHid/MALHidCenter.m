//
//  MALHid.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALInputPrivate.h"

static NSDictionary * usageTables = nil;
static NSMutableSet * connectedDevices = nil;
static NSDictionary * deviceNamespaces = nil;

@implementation MALHidCenter
;
#pragma mark element/device descriptions

-(NSDictionary *) descriptionsForDevice:(IOHIDDeviceRef)device {
	return usageTables[@"ElementIdentifier"][[self descriptionForDevice:device]];
}
-(NSString *) descriptionForDevice:(IOHIDDeviceRef)device {
	MALHidUsage usage = [MALInputDevice usageForDevice:device];
	
	NSDictionary * generalDescriptions = [usageTables objectForKey:@"DeviceIdentifier"];
	NSString * format = [generalDescriptions objectForKey:[NSString stringWithFormat:@"%x.%x",usage.page,usage.ID]];
	
	return [NSString stringWithFormat:format,
			[getHIDDeviceProperty(device, kIOHIDVendorIDKey) intValue],
			[getHIDDeviceProperty(device, kIOHIDProductIDKey) intValue],
			[getHIDDeviceProperty(device, kIOHIDVersionNumberKey) intValue]];
}
-(NSString *) descriptionForElement:(IOHIDElementRef)element {
	MALHidUsage usage = [MALInputElement usageForElement:element];
	NSDictionary * elementDescriptions = [self descriptionsForDevice:IOHIDElementGetDevice(element)];
	
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

#pragma mark IOHIDCenter callbacks

-(void) deviceInput:(IOHIDValueRef)value {
	IOHIDElementRef element = IOHIDValueGetElement(value);
	MALInputElement * obj = [hidElements objectForKey:[MALInputElement keyForElement:element]];
	[obj valueChanged:value];
}
-(void) deviceRemoval:(IOHIDDeviceRef)device {
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	int location = [getHIDDeviceProperty(device, kIOHIDLocationIDKey) intValue];
	
	NSString * desc = [[MALHidCenter shared] descriptionForDevice:device];
	
	printf("Disconnect: %x %s #%x_%x\n",location, [desc UTF8String], usagePage, usageID);
	
	[connectedDevices removeObject:[NSString stringWithFormat:@"%x.%x.%x", location, usagePage, usageID]];
}
-(void) deviceConnection:(IOHIDDeviceRef)deviceRef {
	NSString * deviceID = [self descriptionForDevice:deviceRef];
	if(!deviceID) return;
	
	NSString * deviceName = [self descriptionsForDevice:deviceRef][@"Description"];
	if(!deviceName) deviceName = deviceID;
	
	// Get/Make the aliases that this device matches
	MALInputDevice * deviceGeneral = [[MALInputCenter shared] deviceAtPath:deviceID];
	if(!deviceGeneral) {
		deviceGeneral = [MALInputDevice device];
		deviceGeneral.deviceID = deviceID;
		deviceGeneral.name = deviceName;
		deviceGeneral.location = 0;
		[[MALInputCenter shared] addDevice:deviceGeneral atPath:deviceID];
	}
	deviceGeneral.location = [getHIDDeviceProperty(deviceRef, kIOHIDLocationIDKey) intValue];
	MALInputDevice * deviceSpecific = [[MALInputCenter shared] deviceAtPath:deviceGeneral.devicePath];
	if(!deviceSpecific) {
		deviceSpecific = [MALInputDevice device];
		deviceSpecific.deviceID = deviceID;
		deviceSpecific.name = deviceName;
		deviceSpecific.location = deviceGeneral.location;
		[[MALInputCenter shared] addDevice:deviceSpecific atPath:deviceSpecific.devicePath];
		
		NSLog(@"Device connection :: %@", deviceSpecific.devicePath);
	}
	deviceGeneral.location = 0;
	
	
	// Check which elements should be added to the device
	NSArray * elements = [(NSArray*)IOHIDDeviceCopyMatchingElements(deviceRef, NULL, kIOHIDOptionsTypeNone) autorelease];
	for(id _element in elements) {
		IOHIDElementRef element = (IOHIDElementRef)_element;
		
		MALHidUsage hidUsage = [MALInputElement usageForElement:element];
		if([[[MALHidCenter shared] descriptionForPage:hidUsage.page usage:hidUsage.ID] hasPrefix:@"Unknown"])
			continue;
		
		//Only want end elements
		IOHIDElementType type = IOHIDElementGetType(element);
		if(type == kIOHIDElementTypeCollection || type == kIOHIDElementTypeFeature) continue;
		
		for(MALElementConnectionObserver modifier in elementConnectionObservers) {
			NSArray* newElements = modifier(element);
			if(!newElements) continue;
			
			for(MALInputElement* element in newElements) {
				if([[element elementID] isEqualToString:@"_ignore_"])
					continue;
//				if(![[deviceGeneral deviceID] isEqualToString:@"Key"])
//					NSLog(@"add: %@ %@",[deviceGeneral devicePath], [element elementID]);
				[deviceSpecific setElement:element forPath:element.elementID];
				[deviceGeneral setElement:element forPath:element.elementID];
			}
			
			break;
		}
	}
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
-(BOOL) addObserver:(MALInputElement*)o forHIDElement:(IOHIDElementRef)e {
	if(!o) return NO;
	id key = [NSValue valueWithPointer:e];
	if([hidElements objectForKey:key]) return NO;
	[hidElements setObject:o forKey:key];
	return YES;
}
-(void) removeObserver:(MALInputElement*)o {
	for(id key in [hidElements allKeysForObject:o])
		[hidElements removeObjectForKey:key];
}

#pragma mark creation/destruction
+(MALHidCenter *) shared {
	static MALHidCenter * shared = nil;
	if(!shared) {
		shared = [[self alloc] _init];
	}
	return shared;
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
		// default
		[self addElementConnectionObserver:^NSArray*(IOHIDElementRef element) {
			return @[[MALInputElement elementWithHIDElement:element]];
		}];
		// fixes up Hatswitches so that they're easier to work with
		[self addElementConnectionObserver:^NSArray*(IOHIDElementRef element) {
			MALHidUsage usage = [MALInputElement usageForElement:element];
			if(usage.page == 0x1 && usage.ID == 0x39) {
				
#define setElementID(element,ID) element.elementID = [NSString stringWithFormat:@"%@." ID , draw.elementID]
#define one 0x1000
				
				MALInputElement *draw = [MALInputElement elementWithHIDElement:element];
				draw.isDiscoverable = NO;
				
				MALInputElement *dup=[MALInputElement element],*ddown=[MALInputElement element],
								*dright=[MALInputElement element],*dleft=[MALInputElement element],
								*dx=[MALInputElement element],*dy=[MALInputElement element];
				
				setElementID(dup, "up"); setElementID(ddown, "down"); setElementID(dright, "right");
				setElementID(dleft, "left"); setElementID(dx, "x"); setElementID(dy, "y");
				
				dx.rawMax = one; dy.rawMax = one;
				dx.rawMin = -one; dy.rawMin = -one;
				[draw addObserver:^(MALIOElement *e) {
					// Some hatswitches don't have NW SW NE SE, i.e. just N E S W
					long value8 = (e.rawMax == 3 ? 2*e.rawValue : e.rawValue);
					long x, y, s2 = sqrtf(.5)*one;
					uint64_t t = e.timestamp;
					
					switch (value8) { // clockwise from north
						case 0: x=0; y=one; break;
						case 1: x=s2; y=s2; break;
						case 2: x=one; y=0; break;
						case 3: x=s2; y=-s2; break;
						case 4: x=0; y=-one; break;
						case 5: x=-s2; y=-s2; break;
						case 6: x=-one; y=0; break;
						case 7: x=-s2; y=s2; break;
						default: x=0;y=0; break; // null value
					}
					
					[dx updateValue:x timestamp:t];
					[dy updateValue:y timestamp:t];
					[dup    updateValue:y > 0 ? 1:0 timestamp:t];
					[dright updateValue:x > 0 ? 1:0 timestamp:t];
					[ddown  updateValue:y < 0 ? 1:0 timestamp:t];
					[dleft  updateValue:x < 0 ? 1:0 timestamp:t];
				}];
				return @[draw,dup,ddown,dright,dleft,dx,dy];
#undef setElementID
#undef one
			}
			return nil;
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