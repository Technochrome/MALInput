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
	NSMutableArray * observers;
	NSString * path;
	
	// does this provide enough to deliniate between different types? 0D, 1D, 2D, 3D
	long value,min,max;
	
	MALHidUsage hidUsage;
	
	int isRelative:1;
	int isAbsolute:1;
	int isDiscoverable:1; // will notify InputCenter of changes, 
	
	// timestamp of new, of last
	// flag for if it is raw (i.e. not the best representation (e.g. hatswitch))
}

-(MALHidUsage) usage;
-(NSString*) pathOfType:(MALInputPathType)type;
-(void) setPath:(NSString*)path;

-(void) updateValue:(long)value timestamp:(uint64_t)t;

-(void) addObserver:(id)observer;
-(void) removeObserver:(id)observer;

-(BOOL) isScalar;
// Some devices can do both, e.g. joysticks
-(BOOL) isRelative;
-(BOOL) isAbsolute;
@end
