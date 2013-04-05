//
//  MALInputCenter.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"
#import "MALIODevice.h"

@implementation MALInputCenter
@synthesize inputListener;

+(void) load {
	fixHatswitch = ^BOOL (MALInputElement *el) {
		MALHidUsage usage = [el usage];
		if(usage.page == 0x1 && usage.ID == 0x39) {
			//FIXME
		}
		return YES;
	};
}

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
		elements = [[NSMutableDictionary alloc] init];
		devices = [[NSMutableDictionary alloc] init];
		userElements = [[NSMutableDictionary alloc] init];
		elementModifiers = [[NSMutableArray alloc] init];
		
		[self addDevice:[MALIODevice device] atPath:@"mouse"];
		[self addDevice:[MALIODevice device] atPath:@"key"];
	}
	return self;
}
-(id) init {
	@throw [NSException exceptionWithName:@"Don't call [[MALInputCenter alloc] init]"
								   reason:@"Use [MALInputCenter shared] instead."
								 userInfo:nil];
}
-(void) dealloc {
	[elements release]; [userElements release]; [elementModifiers release]; [devices release];
	[super dealloc];
}

-(void) addElementModifier:(inputElementModifier)mod {
	[elementModifiers addObject:mod];
}

-(void) valueChanged:(MALInputElement*)element {
	if(inputListener) inputListener(element);
}

-(MALInputProfile*) setPath:(NSString*)path toProfile:(MALInputProfile*)profile {
	[self removeProfileAtPath:path];
	
	profile = [profile copy];
	[userElements setValue:profile forKey:path];
	[profile release];
	
	for(NSString *path in [profile boundKeys]) {
		MALIOElement *input = [profile inputElementForKey:path], *output = [profile outputElementForKey:path];
		[input addObserver:output];
	}
	return profile;
}
-(void) removeProfileAtPath:(NSString*)path {
	MALInputProfile * profile = [userElements objectForKey:path];
	
	for(NSString *path in [profile boundKeys]) {
		MALIOElement *input = [profile inputElementForKey:path], *output = [profile outputElementForKey:path];
		[input removeObserver:output];
	}
	
	[userElements removeObjectForKey:path];
}

#pragma mark element/device management

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path {
	[elements setObject:input forKey:path];
}
-(MALInputElement*) inputAtPath:(NSString *)path {
	return [elements objectForKey:path];
}
-(void) removeInputAtPath:(NSString *)path {
	[elements removeObjectForKey:path];
}
-(void) addDevice:(MALIODevice*)device atPath:(NSString*)path {
	[devices setObject:device forKey:path];
}
-(MALIODevice*) deviceAtPath:(NSString*)path {
	return [devices objectForKey:path];
}
-(void) removeDeviceAtPath:(NSString*)path {
	[devices removeObjectForKey:path];
}
@end
