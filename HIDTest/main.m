//
//  main.m
//  HIDTest
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/*
 As devices get added, their type determines what function handles them
 the default action is to ignore devices not on the white-list
 User-actions include
	-changing the hat device to a joystick
	-scaling the mouse/joystick correctly
 
	-Need to think about how to handle mouse input, because it's more difficult than buttons
 
 The HIDCenter captures all input from those devices, effects user-defined values
 
 
 
 */



#import <Foundation/Foundation.h>
#import "MALInput.h"


int main (int argc, const char * argv[]) {
	@autoreleasepool {
		MALIOObserverBlock dumpEverything = ^(MALIOElement* input) {
			NSLog(@"%@ : %lx",input, [input rawValue]);
		};
		
		MALInputProfile *a;//, *b=nil;
		a = [[MALInputProfile alloc] init];
		MALOutputElement *output = [MALOutputElement boolElement];
		[output addObserver:dumpEverything];
		[a setOutput:output forKey:@"test"];
		
		__block MALInputProfile *profile = a;
		
		MALInputCenter *i = [MALInputCenter shared];
		[i startListening];
		
		[i setInputListener:^(MALInputElement *inputElement) {
			MALHidUsage usage = [inputElement usage];
			if(usage.page == 0x7 && usage.ID == 0x29) {
				[i setPath:@"testControl" toProfile:profile];
//				c = (c==a? b : a);
				return;
			}
			
			if([inputElement isBoolean]) {
				if([inputElement boolValue]) {
					[profile setInput:inputElement forKey:@"test"];
				}
			} else if(![inputElement isRelative]) {
				float value = [inputElement floatValueFrom:-1 to:1 deadzone:.1];
				if(value != 0) if(NO) NSLog(@"%f, (%ld,%ld,%ld)",value,[inputElement rawValue],[inputElement rawMin],[inputElement rawMax]);
			}
		}];
		
		[[NSRunLoop currentRunLoop] run];
	}
    return 0;
}

