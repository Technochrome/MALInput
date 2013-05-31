//
//  NSObject_MALInputPrivate.h
//  MALHid
//
//  Created by Rovolo on 4/11/13.
//
//

#import "MALInput.h"
#import "MALMacros.h"

#define getHIDDeviceProperty(device, key) (NSNumber*)IOHIDDeviceGetProperty(device, CFSTR(key))

@interface MALIOElement ()
@property (readwrite) long rawValue,rawMax,rawMin;
@end

@interface MALInputElement (HID)
+(MALHidUsage) usageForElement:(IOHIDElementRef)e;
+(NSValue*) keyForElement:(IOHIDElementRef)e;

-(MALInputElement*) initWithHIDElement:(IOHIDElementRef)e;
+(MALInputElement*) elementWithHIDElement:(IOHIDElementRef)e;
+(MALInputElement*) element;

-(void) valueChanged:(IOHIDValueRef)value;
@end

@interface MALInputDevice (HID)
+(MALHidUsage) usageForDevice:(IOHIDDeviceRef)device;
@end
