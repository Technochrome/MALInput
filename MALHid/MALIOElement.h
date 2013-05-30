//
//  MALIOElement.h
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import <Foundation/Foundation.h>

@class MALIOElement,MALInputDevice;

typedef void (^MALIOObserverBlock)(MALIOElement*);
typedef void (^MALIOValueModifierBlock)(MALIOElement* src, MALIOElement *dest);

@interface MALIOElement : NSObject <NSCopying> {
	__weak MALInputDevice * specificDevice, *generalDevice;
	
	NSMutableSet * observers; // Takes blocks
	
	long rawMin,rawMax;
	long value,oldValue;
	uint64_t timestamp,oldTimestamp;
	float fMax,fMin,fDeadzone;
	
	BOOL isRelative:1;
	BOOL isWrapping:1;
	BOOL isDiscoverable:1; // will notify InputCenter of changes,
}
@property (readonly) uint64_t timestamp,oldTimestamp;
@property (readonly) long rawValue,rawMax,rawMin;
@property (readonly) BOOL isRelative,isWrapping;
@property (readwrite) MALIOValueModifierBlock valueModifier;
@property (readwrite) BOOL isDiscoverable;
@property (readwrite, weak) MALInputDevice * specificDevice, *generalDevice;
@property (readwrite) float fMax,fMin,fDeadzone;

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
-(void) valueUpdated:(MALIOElement*)element;

@end
