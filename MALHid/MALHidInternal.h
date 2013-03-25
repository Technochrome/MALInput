//
//  MALHidInternal.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MALHid_MALHidInternal_h
#define MALHid_MALHidInternal_h



#import "MALMacros.h"


#define getHIDDeviceProperty(device, key) (NSNumber*)IOHIDDeviceGetProperty(device, CFSTR(key))
#define getHIDElementProperty(element, key) [(NSNumber*)IOHIDElementGetProperty(element, CFSTR(key)) autorelease]

#import "MALInput.h"

#endif
