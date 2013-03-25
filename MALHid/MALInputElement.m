//
//  MALInputElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@implementation MALInputElement
@synthesize usage=hidUsage,path;

-(id) init {
	if((self = [super init])) {
		observers = [[NSMutableSet alloc] init];
	} return self;
}
-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	[super updateValue:newValue timestamp:t];
	if(isDiscoverable) [[MALInputCenter shared] valueChanged:self];
}

-(void) setPath:(NSString*)p {
	if(path) [[MALInputCenter shared] removeInputAtPath:path];
	
	path = [p copy];
	
	if(path) [[MALInputCenter shared] addInput:self atPath:path];
}

-(NSString*) controllerName {
	return @"No controller name";
}
-(NSString*) inputName {
	return @"No input name";
}
@end
