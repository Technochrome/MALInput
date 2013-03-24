//
//  MALInputCenter.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MALInputElement,MALInputProfile;

typedef void (^inputListenerType)(MALInputElement*);
typedef BOOL (^inputElementModifier)(MALInputElement*);

inputElementModifier fixHatswitch;

@interface MALInputCenter : NSObject {
	NSMutableDictionary *elements, *userElements;
	
	NSMutableArray *elementModifiers;
	
	inputListenerType inputListener;
}
@property (readwrite, strong) inputListenerType inputListener;

+(MALInputCenter*) shared;
-(void) startListening;

-(void) addElementModifier:(inputElementModifier)mod;


// NOT FOR USERS
-(void) setPath:(NSString*)path toProfile:(MALInputProfile*)profile;
-(void) removeProfileAtPath:(NSString*)path;

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path;

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path;
-(MALInputElement*) inputAtPath:(NSString*)path;
-(void) removeInputAtPath:(NSString*)path;
@end
