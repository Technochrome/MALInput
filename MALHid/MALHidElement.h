//
//  MALHidElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// joystick normalize
// D-pad normalize
// something with mouse pointer?

@class MALInputElement;

@interface MALHidElement : MALInputElement {
@private
	
	IOHIDElementRef element;
}
-(IOHIDDeviceRef) device;
-(int) cookie;

+(MALHidUsage) usageForElement:(IOHIDElementRef)e;
+(NSValue*) keyForElement:(IOHIDElementRef)e;
+(id) hidElementWithElement:(IOHIDElementRef)e;
-(id) initWithElement:(IOHIDElementRef)e;

-(void) valueChanged:(IOHIDValueRef)value;
@end