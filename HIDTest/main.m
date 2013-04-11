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
#import "NSDictionary+toINI.h"

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
		for(int i=0; i<10; i++) {
			MALOutputElement * el = [MALOutputElement boolElement];
			id key = [NSString stringWithFormat:@"%d",i];
			[el addObserver:dumpEverything(key)];
			[a setOutput:el forKey:key];
		}		
		__block MALInputProfile *profile = a;
		__block int bound = 0;
		
		MALInputCenter *i = [MALInputCenter shared];
		[i startListening];
		
		NSString * goodBindingsINI = [NSString stringWithContentsOfFile:@"bindings.ini" encoding:NSUTF8StringEncoding error:NULL];
		NSDictionary * goodBindings = [[NSDictionary dictionaryWithINI:goodBindingsINI] retain];
		NSLog(@"%@",goodBindings);
		
		[i setInputListener:^(MALInputElement *inputElement) {
			MALHidUsage usage = [inputElement usage];
			
			if([inputElement isBoolean]) {
				if([inputElement boolValue]) {
//					NSLog(@"%@",[inputElement fullID]);
					if(usage.page == 0x7 && usage.ID == 0x29) {
						[a loadBindings:goodBindings];
						
						NSMutableArray * devices = [NSMutableArray array];
						for(NSString * deviceID in [a inputDevices]) {
							NSArray * matchingDevices = [i devicesWithID:deviceID];
							[devices addObject:matchingDevices[0]];
						}
						[i addDeviceAtPath:@"input" usingProfile:a withDevices:devices];
						
						//				c = (c==a? b : a);
//						NSLog(@"\n%@",[@{@"bindings":[a bindingsByID]} toINI]);
//						[[[a bindingsByID] toINI] writeToFile:@"bindings.ini" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
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

