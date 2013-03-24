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

@class MALHidElement;

@interface MALHidCenter : NSObject {
	NSMutableDictionary * rawValueDict;
	NSDictionary * mLookupTables;
}
+(MALHidCenter *) shared;
-(void) startListening;

-(BOOL) addObserver:(MALHidElement*)o forElement:(IOHIDElementRef)e;
-(void) removeObserver:(MALHidElement*)o;
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usage;

-(void) newValue:(IOHIDValueRef)value;
@end