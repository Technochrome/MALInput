//
//  MALInputCenter.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MALInputElement;

typedef void (^inputListenerType)(MALInputElement*);

@interface MALInputCenter : NSObject {
	NSMutableDictionary * elements, *deviceToPath;
	
	inputListenerType inputListener;
}
@property (readwrite, strong) inputListenerType inputListener;

+(MALInputCenter*) shared;

-(void) valueChanged:(MALInputElement*)element path:(NSString*)path;

-(void) addInput:(MALInputElement*)input atPath:(NSString*)path;
-(MALInputElement*) inputAtPath:(NSString*)path;
-(void) removeInputAtPath:(NSString*)path;
@end
