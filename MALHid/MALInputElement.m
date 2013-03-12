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
@synthesize isRelative,isWrapping;

-(MALHidUsage) usage {
	if(hidUsage.page == 0 && hidUsage.ID == 0) printf("---------------------\n");
	return hidUsage;}

-(void) setPath:(NSString*)p {
	if(path) [[MALInputCenter shared] removeInputAtPath:path];
	
	path = [p copy];
	
	[[MALInputCenter shared] addInput:self atPath:path];
}

-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	value = newValue;
	[[MALInputCenter shared] valueChanged:self path:path];
}

-(NSString*) pathOfType:(MALInputPathType)type {return nil;}
-(NSString*) path {return nil;}

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
	printf("%f ",sVal);
	
	// Lop off the deadzone from the middle. [0,1] => [0+deadzone,1-deadzone]
	sVal = (sVal > .5 ? MAX(.5,sVal-deadzone) : MIN(.5, sVal+deadzone));
	printf("%f ",sVal);
	
	// [0+deadzone,1-deadzone] => [0,1]
	sVal = (sVal - deadzone)/(1-2*deadzone);
	printf("%f ",sVal);
	
	// [0,1] => [min, max]
	sVal = sVal*(to-from) + from;
	printf("%f\n",sVal);
	return sVal;
}
@end
