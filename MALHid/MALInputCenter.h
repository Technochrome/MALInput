//
//  MALInputCenter.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@class MALInputElement,MALInputProfile,MALIODevice;

typedef void (^inputListenerType)(MALInputElement*);
typedef BOOL (^inputElementModifier)(MALInputElement*);

inputElementModifier fixHatswitch;

@interface MALInputCenter : NSObject {
	NSMutableDictionary *elements, *userElements;
	NSMutableDictionary *devices;
	
	NSMutableArray *elementModifiers;
	
	inputListenerType inputListener;
}
@property (readwrite, strong) inputListenerType inputListener;

+(MALInputCenter*) shared;
-(void) startListening;

-(void) addElementModifier:(inputElementModifier)mod;

-(MALIODevice*) addDeviceAtPath:(NSString*)path usingProfile:(MALInputProfile*)profile withDevices:(NSArray*)devices;

-(NSArray*) devicesWithID:(NSString*)deviceID;

// NOT FOR USERS
-(void) valueChanged:(MALInputElement*)element;

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path;
-(MALInputElement*) inputAtPath:(NSString*)path;
-(void) removeInputAtPath:(NSString*)path;

-(void) addDevice:(MALIODevice*)device atPath:(NSString*)path;
-(MALIODevice*) deviceAtPath:(NSString*)path;
-(void) removeDeviceAtPath:(NSString*)path;
@end
