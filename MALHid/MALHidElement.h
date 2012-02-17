//
//  MALHidElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@interface MALHidElement : NSObject {
@private
	IOHIDElementRef element;
	
	NSMutableArray * observers;
	
	int value,min,max;
	//timestamp of new, of last
}
-(IOHIDDeviceRef) device;
-(MALHidUsage) usage;
-(int) cookie;

+(NSString*) keyForElement:(IOHIDElementRef)e;
-(id) initWithElement:(IOHIDElementRef) e namespace:(NSString*)ns;
@end