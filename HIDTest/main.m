//
//  main.m
//  HIDTest
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MALHid.h"

int main (int argc, const char * argv[]) {
	@autoreleasepool {
	    
	    // insert code here...
	    NSLog(@"Hello, World!");
	    
		
		getDevices();
		
		[[NSRunLoop currentRunLoop] run];
	}
    return 0;
}

