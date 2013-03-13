//
//  MALInputElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidStructs.h"

@class MALInputElement;
typedef void (^MALInputObserverBlock)(MALInputElement*);

@interface MALInputElement : NSObject {
	NSMutableSet * observers; // Takes blocks
	NSString * path;
	
	long rawMin,rawMax;
	long value,oldValue;
	uint64_t timestamp,oldTimestamp;
	
	MALHidUsage hidUsage;
	
	BOOL isRelative:1;
	BOOL isWrapping:1;
	BOOL isDiscoverable:1; // will notify InputCenter of changes,
}
@property (readonly) long rawValue,rawMax,rawMin;
@property (readonly) BOOL isRelative,isWrapping;
@property (readwrite) BOOL isDiscoverable;
@property (readwrite,copy,nonatomic) NSString * path;

-(MALHidUsage) usage;

-(void) addObserver:(MALInputObserverBlock)observer;
-(void) removeObserver:(MALInputObserverBlock)observer;

// Query input type
-(BOOL) isBoolean;
-(BOOL) isRelative;

// Query value
-(BOOL) boolValue;
-(float) floatValue;
-(float) floatValueFrom:(float)from to:(float)to;
// The deadzone is a percentage of the range [min, max]
-(float) floatValueFrom:(float)from to:(float)to deadzone:(float)deadzone;

-(void) updateValue:(long)value timestamp:(uint64_t)t;

// Somehow look at history

-(NSString*) controllerName;
-(NSString*) inputName;
@end
