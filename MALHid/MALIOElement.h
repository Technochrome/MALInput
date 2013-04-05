//
//  MALIOElement.h
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import <Foundation/Foundation.h>

@class MALIOElement,MALIODevice;

typedef void (^MALIOObserverBlock)(MALIOElement*);
typedef int (^MALInputValueModifier)(long);

@interface MALIOElement : NSObject <NSCopying> {
	MALIODevice * device;
	
	NSMutableSet * observers; // Takes blocks
	
	long rawMin,rawMax;
	long value,oldValue;
	uint64_t timestamp,oldTimestamp;
	
	BOOL isRelative:1;
	BOOL isWrapping:1;
	BOOL isDiscoverable:1; // will notify InputCenter of changes,
}
@property (readonly) long rawValue,rawMax,rawMin;
@property (readonly) BOOL isRelative,isWrapping;
@property (readwrite) BOOL isDiscoverable;
@property (readwrite, copy) MALInputValueModifier inputModifier;

-(void) addObserver:(id)observer;
-(void) removeObserver:(id)observer;

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

@end
