//
//  MALHidElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "MALInputElement.h"
#import "MALHidInternal.h"

// joystick normalize
// D-pad normalize
// something with mouse pointer?

@interface MALHidElement : MALInputElement {
@private
	float scaleMax,scaleMin;
	
	IOHIDElementRef element;
}
-(IOHIDDeviceRef) device;
-(int) cookie;

+(NSString*) keyForElement:(IOHIDElementRef)e;
+(id) hidElementWithElement:(IOHIDElementRef)e;
-(id) initWithElement:(IOHIDElementRef) e namespace:(NSString*)ns;

-(void) valueChanged:(IOHIDValueRef)value;
@end