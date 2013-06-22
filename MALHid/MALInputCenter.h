//
//  MALInputCenter.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@class MALInputElement,MALInputProfile,MALInputDevice;

typedef void (^inputListenerType)(MALInputElement*);

extern NSString * MALInputDeviceConnectionNotification;
extern NSString * MALInputDeviceDisconnectionNotification;

@interface MALInputCenter : NSObject {
	NSMutableDictionary *devices;
	
	inputListenerType inputListener;
}
@property (readwrite, strong) inputListenerType inputListener;

+(MALInputCenter*) shared;
-(void) startListening;

-(MALInputDevice*) addDeviceAtPath:(NSString*)path usingProfile:(MALInputProfile*)profile withDevices:(NSArray*)devices;

-(NSArray*) devicesPassingTest:(BOOL (^) (MALInputDevice*))test;
-(NSArray*) devicesWithID:(NSString*)deviceID;
-(NSArray*) devicesWithIDPrefix:(NSString*)deviceIDPrefix;
-(NSArray*) allDevices;

-(MALInputDevice*) keyboard;
-(MALInputDevice*) mouse;
-(NSArray*) gamepads;

// NOT FOR USERS
-(void) valueChanged:(MALInputElement*)element;

-(void) addDevice:(MALInputDevice*)device atPath:(NSString*)path;
-(MALInputDevice*) deviceAtPath:(NSString*)path;
-(void) removeDeviceAtPath:(NSString*)path;
@end
