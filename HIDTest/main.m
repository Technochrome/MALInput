//
//  main.m
//  HIDTest
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/*
	-Need to think about how to handle mouse input, because it's more difficult than buttons
 */



#import <Foundation/Foundation.h>
#import "MALInput.h"

MALIOObserverBlock dumpEverything(NSString* str);
MALIOObserverBlock dumpEverything(NSString* str) {
	return [[^(MALIOElement* input) {
		NSLog(@"%@ : %lx",str, [input rawValue]);
	} copy] autorelease];
}


int main (int argc, const char * argv[]) {
	@autoreleasepool {
		
		MALInputProfile *a;//, *b=nil;
		a = [[MALInputProfile alloc] init];
		MALOutputElement *output1 = [MALOutputElement boolElement], *output2 = [MALOutputElement boolElement];
		[output1 addObserver:dumpEverything(@"1")];
		[a setOutput:output1 forKey:@"1"];
		[output2 addObserver:dumpEverything(@"2")];
		[a setOutput:output2 forKey:@"2"];
		
		__block MALInputProfile *profile = a;
		__block int bound = 1;
		
		MALInputCenter *i = [MALInputCenter shared];
		[i startListening];
		
		NSDictionary * bindings = @{
			@"1":@"7(1.30)(1.4)14200000.300",
			@"2":@"6(1.30)(1.4)14200000.300"
		};
		NSDictionary * goodBindings = @{
			@"1": @"mouse.1.30", //@"mouse.x"
			@"2": @"key.9.4", //@"key.a"
			@"3": @"joy(14200000.300).1.30.7"
		};
		goodBindings = nil;
		
		[i setInputListener:^(MALInputElement *inputElement) {
			MALHidUsage usage = [inputElement usage];
			
			if([inputElement isBoolean]) {
				if([inputElement boolValue]) {
					NSLog(@"%@",[inputElement fullID]);
					if(usage.page == 0x7 && usage.ID == 0x29) {
						NSLog(@"%@",[profile bindingsByID]);
						//				c = (c==a? b : a);
						return;
					}
					[profile setInput:inputElement forKey:[NSString stringWithFormat:@"%d",bound++]];
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

