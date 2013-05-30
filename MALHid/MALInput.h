//
//  MALInput.h
//  MALHid
//
//  Created by Rovolo on 3/12/13.
//
//

#ifndef MALHid_MALInput_h
#define MALHid_MALInput_h

typedef struct {
	unsigned page,ID;
} MALHidUsage;

MALHidUsage MakeMALHidUsage(unsigned page, unsigned ID);

#endif

#ifdef __OBJC__

#import <IOKit/hid/IOHIDLib.h>
#import <Foundation/Foundation.h>

#import "MALIOElement.h"
#import "MALInputElement.h"
#import "MALOutputElement.h"

#import "MALInputCenter.h"
#import "MALHidCenter.h"
#import "MALInputProfile.h"

#import "MALInputDevice.h"

#endif
