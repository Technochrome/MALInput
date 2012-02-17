//
//  MALHidInternal.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MALHid_MALHidInternal_h
#define MALHid_MALHidInternal_h


#include <IOKit/hid/IOHIDLib.h>
#import <Foundation/Foundation.h>

#include "MALHid.h"
#import "MALMacros.h"


#define getHIDDeviceProperty(device, key) [(NSNumber*)IOHIDDeviceGetProperty(device, CFSTR(key)) autorelease]

#include "MALHidStructs.h"

#import "MALHidCenter.h"
#import "MALHidElement.h"

#endif
