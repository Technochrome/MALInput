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

@interface MALInputElement (HID)
+(MALHidUsage) usageForElement:(IOHIDElementRef)e;
+(NSValue*) keyForElement:(IOHIDElementRef)e;
+(MALInputElement*) elementWithHIDElement:(IOHIDElementRef)e;
-(MALInputElement*) initWithHIDElement:(IOHIDElementRef)e;

-(void) valueChanged:(IOHIDValueRef)value;
@end

@interface MALInputDevice (HID)
+(MALHidUsage) usageForDevice:(IOHIDDeviceRef)device;
@end
