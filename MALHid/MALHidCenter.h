//
//  MALHid.h
//  MALHid
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// 3 major devices right now [Key, Mouse, Joy]
// refer by Joy, Joy[0]
// each device should have a connected/disconnected attribute (or should absense be attribute?)

@class MALInputDevice;

typedef NSArray* (^MALElementConnectionObserver)(IOHIDElementRef element);

@interface MALHidCenter : NSObject {
	NSMutableDictionary * hidElements, *devices;
	NSDictionary * mLookupTables;
	NSMutableArray * elementConnectionObservers;
	
	IOHIDManagerRef ioManager;
	
	BOOL isListening;
}
+(MALHidCenter *) shared;
-(void) startListening;

-(void) addElementConnectionObserver:(MALElementConnectionObserver)modifier;

-(BOOL) addObserver:(MALInputElement*)o forHIDElement:(IOHIDElementRef)e;
-(void) removeObserver:(MALInputElement*)o;
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usage;
-(NSDictionary *) descriptionsForDevice:(IOHIDDeviceRef)device;
-(NSString *) descriptionForDevice:(IOHIDDeviceRef)device;
-(NSString *) descriptionForElement:(IOHIDElementRef)element;
@end