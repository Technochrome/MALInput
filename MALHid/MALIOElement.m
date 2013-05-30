//
//  MALIOElement.m
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import "MALInputPrivate.h"

@implementation MALIOElement
@synthesize rawValue=value,rawMax,rawMin;
@synthesize isRelative,isWrapping,isDiscoverable,specificDevice, generalDevice;
@synthesize fMax,fMin,fDeadzone,timestamp,oldTimestamp,valueModifier;

-(id) init {
	if((self = [super init])) {
		observers = [[NSMutableSet alloc] init];
	} return self;
}

-(void) valueUpdated:(MALIOElement*)element {
	if(valueModifier) valueModifier(element,self);
	else [self updateValue:element.rawValue timestamp:element.timestamp];
}
-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	oldValue = value; value = newValue;
	oldTimestamp = timestamp; timestamp = t;
	for(id obj in observers) {
		if([(id)obj isKindOfClass:[MALIOElement class]]) {
			[obj valueUpdated:self];
		} else {
			MALIOObserverBlock block = obj;
			block(self);
		}
	}
}

-(void) addObserver:(id)observer {
	[observers addObject:observer];
}

-(void) removeObserver:(id)observer	{
	[observers removeObject:observer];
}

#pragma mark Query Input Type
-(BOOL) isBoolean {return (rawMax-rawMin) == 1;}

#pragma makr Query Input Value
-(BOOL) boolValue {
	return value;
}
-(float) floatValue {
	return [self floatValueFrom:fMin to:fMax deadzone:fDeadzone];
}
-(float) floatValueFrom:(float)from to:(float)to {
	return [self floatValueFrom:from to:to deadzone:fDeadzone];
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

-(id) copyWithZone:(NSZone *)zone {
	MALIOElement * el = [[[self class] allocWithZone:zone] init];
	el->observers = [observers mutableCopy];
	el->rawMin = rawMin; el->rawMax = rawMax;
	el->value = value; el->oldValue = oldValue;
	el->timestamp = timestamp; el->oldTimestamp = oldTimestamp;
	el->isRelative = isRelative; el->isWrapping = isWrapping; el->isDiscoverable = isDiscoverable;
	el->fDeadzone = fDeadzone; el->fMin = fMin; el->fMax = fMax;
	
	return el;
}

-(void) dealloc {
	[observers release];
	[super dealloc];
}
@end
