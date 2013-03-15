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

+(void) initialize {
	[MALHidCenter shared];
}
+(MALInputCenter*) shared {
	static id shared = nil;
	if(!shared) shared = [[self alloc] init];
	return shared;
}
-(id) init {
	if((self = [super init])) {
		elements = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path {
	if(inputListener) inputListener(element);
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
@end
