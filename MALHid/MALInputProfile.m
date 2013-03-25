//
//  MALInputProfile.m
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import "MALInputProfile.h"
#import "MALInputCenter.h"

@implementation MALInputProfile
@synthesize inputs,outputs;

-(id) init {
	if((self = [super init])) {
		inputs = [[NSMutableDictionary alloc] init];
		outputs = [[NSMutableDictionary alloc] init];
	} return self;
}


-(void) setOutput:(MALOutputElement*)e forKey:(NSString*)key {
	if(!e) [outputs removeObjectForKey:key];
	else [outputs setValue:e forKey:key];
}
-(void) setInput:(MALInputElement*)e forKey:(NSString*)key {
	if(!e) [inputs removeObjectForKey:key];
	else [inputs setValue:e forKey:key];
}
-(MALOutputElement*) outputElementForKey:(NSString*)key {
	return [outputs valueForKey:key];
}
-(MALInputElement*) inputElementForKey:(NSString*)key {
	return [inputs valueForKey:key];
}

-(NSSet*) boundKeys {
	NSMutableSet *set = [NSMutableSet setWithArray:[outputs allKeys]];
	[set intersectSet:[NSSet setWithArray:[inputs allKeys]]];
	return set;
}
-(NSSet*) unboundKeys {
	NSMutableSet *set = [NSMutableSet setWithArray:[outputs allKeys]];
	[set minusSet:[NSSet setWithArray:[inputs allKeys]]];
	return set;
}
-(void) loadBindings:(NSDictionary*)bindings {
	for(NSString * key in [bindings allKeys]) {
		NSString * value = [bindings objectForKey:key];
		MALInputElement * input = [[MALInputCenter shared] inputAtPath:value];
		[self setInput:input forKey:key];
	}
}
-(NSDictionary*) bindingsByID {
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	for(NSString * key in [self boundKeys]) {
		[ret setValue:[[self inputElementForKey:key] path] forKey:key];
	}
	return ret;
}

-(id) copyWithZone:(NSZone *)zone {
	MALInputProfile * prof = [[[self class] allocWithZone:zone] init];
	[prof->inputs release]; prof->inputs = [inputs mutableCopy];
	[prof->outputs release]; prof->outputs = [outputs mutableCopy];
	
	return prof;
}

-(void) dealloc {
	[inputs release]; [outputs release];
	[super dealloc];
}
@end