//
//  MALInputCenter.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * MALInputMatchDeviceType;
extern NSString * MALInputMatchDevice;
extern NSString * MALInputMatchUseDeviceNumber;

extern NSString * MALInputMatchIsScalar;
extern NSString * MALInputMatchIsRelative;
extern NSString * MALInputMatchIsAbsolute;

@protocol MALInputCallback <NSObject>
-(void) inputFrom:(NSString*)path;
@end

@class MALInputElement;

@interface MALInputCenter : NSObject {
	NSMutableDictionary * devices, *deviceToPath;
	
	id <MALInputCallback> callbackNextInput;
	NSDictionary * nextInputMatchDict;
}
+(MALInputCenter*) shared;

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path;

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path;
-(MALInputElement*) inputAtPath:(NSString*)path;
-(void) removeInputAtPath:(NSString*)path;

-(void) nextInputFromDeviceMatching:(NSDictionary*)matchDictionary callback:(id<MALInputCallback>)callback;
-(void) cancelNextInputCallback;
// define accidental input
@end
