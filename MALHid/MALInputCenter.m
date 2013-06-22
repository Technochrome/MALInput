//
//  MALInputCenter.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALInputPrivate.h"

@implementation MALInputCenter
@synthesize inputListener;

NSString * MALInputDeviceConnectionNotification = @"MALInput device connected";
NSString * MALInputDeviceDisconnectionNotification = @"MALInput device disconnected";

-(void) startListening {
	[[MALHidCenter shared] startListening];
};

+(MALInputCenter*) shared {
	static id shared = nil;
	if(!shared) shared = [[self alloc] _init];
	return shared;
}
-(id) _init {
	if((self = [super init])) {
		devices = [[NSMutableDictionary alloc] init];
	}
	return self;
}
-(id) init {
	@throw [NSException exceptionWithName:@"Don't call [[MALInputCenter alloc] init]"
								   reason:@"Use [MALInputCenter shared] instead."
								 userInfo:nil];
}
-(void) dealloc {
	[devices release];
	[super dealloc];
}

-(void) valueChanged:(MALInputElement*)element {
	if(inputListener) inputListener(element);
}

-(MALInputDevice*) addDeviceAtPath:(NSString *)path usingProfile:(MALInputProfile *)profile withDevices:(NSArray *)inputDevices {
	[self removeDeviceAtPath:path];
	
	MALInputDevice * outputDevice = [MALInputDevice device];
	[self addDevice:outputDevice atPath:path];
	
	for(NSString * key in [profile boundKeys]) {
		MALIOElement * output = [[profile outputElementForKey:key] copy];
		[outputDevice.elements setObject:output forKey:key];
		[output release];

		// bind the new output to the specified input
		NSString * inputID = [profile inputIDForKey:key];
		for(MALInputDevice * d in inputDevices) {
			if([inputID hasPrefix:d.deviceID]) {
				NSString * elementID = [MALInputElement elementIDFromFullID:inputID];
				[[d.elements objectForKey:elementID] addObserver:output];
				break;
			}
		}
	}
	return outputDevice;
}

-(NSArray*) devicesPassingTest:(BOOL (^) (MALInputDevice*))test {
	NSMutableArray * output = [NSMutableArray array];
	for(id key in devices) {
		MALInputDevice * device = devices[key];
		if(test(device)) {
			[output addObject:device];
		}
	}
	return output;
}
-(NSArray*) devicesWithID:(NSString*)deviceID {
	return [self devicesPassingTest:^BOOL(MALInputDevice * device) {
		return device.location!=0 && [device.deviceID caseInsensitiveCompare:deviceID] == NSOrderedSame;
	}];
}
-(NSArray*) devicesWithIDPrefix:(NSString*)deviceIDPrefix {
	return [self devicesPassingTest:^BOOL(MALInputDevice * device) {
		return [device.deviceID hasPrefix:deviceIDPrefix];
	}];
}
-(NSArray*) allDevices {
	return [self devicesPassingTest:^BOOL(MALInputDevice * device) {
		return device.location!=0;
	}];
}
-(MALInputDevice*) keyboard {
	return [self deviceAtPath:@"Key#0"];
}
-(MALInputDevice*) mouse {
	return [self deviceAtPath:@"Mouse#0"];
}
-(NSArray*) gamepads {
	return [self devicesPassingTest:^BOOL(MALInputDevice * device) {
		return [device.deviceID hasPrefix:@"Gamepad"] && device.location != 0;
	}];
}

#pragma mark element/device management

-(void) addDevice:(MALInputDevice*)device atPath:(NSString*)path {
	[devices setObject:device forKey:path];
	[[NSNotificationCenter defaultCenter] postNotificationName:MALInputDeviceConnectionNotification
														object:nil userInfo:@{@"path":path}];
}
-(MALInputDevice*) deviceAtPath:(NSString*)path {
	return [devices objectForKey:path];
}
-(void) removeDeviceAtPath:(NSString*)path {
	[[NSNotificationCenter defaultCenter] postNotificationName:MALInputDeviceDisconnectionNotification
														object:nil userInfo:@{@"path":path}];
	[devices removeObjectForKey:path];
}
@end
