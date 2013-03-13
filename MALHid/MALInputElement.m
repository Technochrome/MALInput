//
//  MALInputElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@implementation MALInputElement
@synthesize rawValue=value,rawMax,rawMin;
@synthesize isRelative,isWrapping,path,isDiscoverable;

-(id) init {
	if((self = [super init])) {
		observers = [[NSMutableSet alloc] init];
		isDiscoverable = YES;
	} return self;
}

-(MALHidUsage) usage {return hidUsage;}

-(void) setPath:(NSString*)p {
	if(path) [[MALInputCenter shared] removeInputAtPath:path];
	
	path = [p copy];
	
	if(path) [[MALInputCenter shared] addInput:self atPath:path];
}

-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	oldValue = value; value = newValue;
	oldTimestamp = timestamp; timestamp = t;
	for(MALInputObserverBlock block in observers) {
		block(self);
	}
	if(isDiscoverable) [[MALInputCenter shared] valueChanged:self path:path];
}

-(void) addObserver:(MALInputObserverBlock)observer {
	[observers addObject:observer];
}

-(void) removeObserver:(MALInputObserverBlock)observer	{
	[observers removeObject:observer];
}

#pragma mark Query Input Type
-(BOOL) isBoolean {return (rawMax-rawMin) == 1;}

#pragma makr Query Input Value
-(BOOL) boolValue {
	return value;
}
-(float) floatValue {
	return [self floatValueFrom:1 to:0];
}
-(float) floatValueFrom:(float)from to:(float)to {
	return [self floatValueFrom:from to:to deadzone:0];
}
-(float) floatValueFrom:(float)from to:(float)to deadzone:(float)deadzone {
	
	// sVal = value in [rawMin,rawMax] => [0,1]
	float sVal = (value - rawMin)/(float)(rawMax-rawMin);
	
	// Lop off the deadzone from the middle. [0,1] => [0+deadzone,1-deadzone]
	sVal = (sVal > .5 ? MAX(.5,sVal-deadzone) : MIN(.5, sVal+deadzone));
	
	// [0+deadzone,1-deadzone] => [0,1]
	sVal = (sVal - deadzone)/(1-2*deadzone);
	
	// [0,1] => [min, max]
	sVal = sVal*(to-from) + from;
	return sVal;
}

-(NSString*) controllerName {
	return @"No controller name";
}
-(NSString*) inputName {
	return @"No input name";
}
@end
