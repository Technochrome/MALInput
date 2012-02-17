//
//  MALHid.h
//  MALHid
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@class MALHidElement;

@interface MALHidCenter : NSObject {
	NSMutableDictionary * rawValueDict;
	NSDictionary * mLookupTables;
}
+(MALHidCenter *) shared;
-(BOOL) addObserver:(MALHidElement*)o forElement:(IOHIDElementRef)e;
-(void) removeObserver:(MALHidElement*)o;
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usage;
@end