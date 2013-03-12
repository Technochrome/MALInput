//
//  MALInputCenter.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

NSString * MALInputMatchDeviceType = @"MALInputMatchDeviceType";
NSString * MALInputMatchDevice = @"MALInputMatchDevice";
NSString * MALInputMatchUseDeviceNumber = @"MALInputMatchUseDeviceNumber";
NSString * MALInputMatchIsRelative = @"MALInputMatchIsRelative";
NSString * MALInputMatchIsScalar = @"MALInputMatchIsScalar";

@implementation MALInputCenter
+(MALInputCenter*) shared {
	static id shared = nil;
	if(!shared) shared = [[self alloc] init];
	return shared;
}
-(id) init {
	self = [super init]; if(!self) return nil;
	
	devices = [[NSMutableDictionary alloc] init];
	
	return self;
}

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path {
	if(callbackNextInput) {
		NSNumber * num = nil;
		
		num = [nextInputMatchDict objectForKey:MALInputMatchIsScalar];
		if(num && ([num boolValue] != [element isScalar])) return;
		
		id c = callbackNextInput;
		[self cancelNextInputCallback];
		[c inputFrom:path];
	}
}

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path {
	[devices setObject:input forKey:path];
}

-(void) nextInputFromDeviceMatching:(NSDictionary*)matchDictionary callback:(id)callback {
	if(callbackNextInput) [self cancelNextInputCallback];
	
	nextInputMatchDict = [matchDictionary retain];
	callbackNextInput = [callback retain];
}
-(void) cancelNextInputCallback {
	[nextInputMatchDict release]; nextInputMatchDict = nil;
	[callbackNextInput release]; callbackNextInput = nil;
}
@end
