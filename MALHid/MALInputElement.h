//
//  MALInputElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidStructs.h"

typedef enum {
	MALInputRawPath, MALInputDeviceTypePath, MALInputDeviceNumberPath
} MALInputPathType;

@interface MALInputElement : NSObject {
	NSMutableArray * observers; // Make this a weak collection
	NSString * path;
	
	long value,rawMin,rawMax;
	
	MALHidUsage hidUsage;
	
	BOOL isRelative:1;
	BOOL isWrapping:1;
	BOOL isDiscoverable:1; // will notify InputCenter of changes,
	
	// timestamp of new, of last
	// flag for if it is raw (i.e. not the best representation (e.g. hatswitch))
}
@property (readonly) long rawValue,rawMax,rawMin;
@property (readonly) BOOL isRelative,isWrapping;

-(MALHidUsage) usage;
-(NSString*) pathOfType:(MALInputPathType)type;
-(void) setPath:(NSString*)path;

-(void) updateValue:(long)value timestamp:(uint64_t)t;

-(void) addObserver:(id)observer;
-(void) removeObserver:(id)observer;

// Query input type
-(BOOL) isBoolean;
-(BOOL) isRelative;
-(BOOL) isAbsolute;

// Query value
-(BOOL) boolValue;
-(float) floatValue;
-(float) floatValueFrom:(float)from to:(float)to;
// The deadzone is a percentage of the range [min, max]
-(float) floatValueFrom:(float)from to:(float)to deadzone:(float)deadzone;

// Somehow look at history

-(NSString*) controllerName;
-(NSString*) inputName;
@end
