//
//  MALInputCenter.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

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
	if(!shared) shared = [[self alloc] init];
	return shared;
}
-(id) init {
	if((self = [super init])) {
		elements = [[NSMutableDictionary alloc] init];
		userElements = [[NSMutableDictionary alloc] init];
		elementModifiers = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addElementModifier:(inputElementModifier)mod {
	[elementModifiers addObject:mod];
}

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path {
	if(inputListener) inputListener(element);
}

-(MALInputProfile*) setPath:(NSString*)path toProfile:(MALInputProfile*)profile {
	profile = [profile copy];
	[userElements setValue:profile forKey:path];
	
	for(NSString *path in [profile allKeys]) {
		MALIOElement *input = [profile inputElementForKey:path], *output = [profile outputElementForKey:path];
		[input addObserver:output];
	}
	return profile;
}
-(void) removeProfileAtPath:(NSString*)path {
	////////
	[userElements removeObjectForKey:path];
}

-(void) removeInputAtPath:(NSString *)path {
	[elements removeObjectForKey:path];
}
-(void) addInput:(MALInputElement*)input atPath:(NSString*)path {
	[elements setObject:input forKey:path];
}
-(MALInputElement*) inputAtPath:(NSString *)path {
	return [elements objectForKey:path];
}

-(void) dealloc {
	[elements release]; [userElements release]; [elementModifiers release];
	[super dealloc];
}
@end
