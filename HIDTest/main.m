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
#import "MALHid.h"

@interface test : NSObject <MALInputCallback> {
	BOOL b;
}
@end

@implementation test
-(void) inputFrom:(NSString *)path {
//	NSLog(@"Input from %@",path);
	
	[[MALInputCenter shared] nextInputFromDeviceMatching:
	 [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:b] forKey:MALInputMatchIsScalar]
												callback:self];
	
	b = !b;
}
@end

int main (int argc, const char * argv[]) {
	printf("%ld\n",sizeof(unsigned));
	@autoreleasepool {
		startMALHidListener();
		MALInputCenter *i = [MALInputCenter shared];
		[i nextInputFromDeviceMatching:
		 [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:MALInputMatchIsScalar]
													callback:[test new]];
		
		[[NSRunLoop currentRunLoop] run];
	}
    return 0;
}

