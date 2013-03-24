//
//  MALInputProfile.m
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import "MALInputProfile.h"

@implementation MALInputProfile

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

-(NSSet*) allKeys {
	NSMutableSet *set = [[NSMutableSet alloc] initWithArray:[outputs allKeys]];
	[set intersectSet:[NSSet setWithArray:[inputs allKeys]]];
	return set;
}
-(NSDictionary*) bindingsByID {
	return nil;
}

-(void) dealloc {
	[inputs release]; [outputs release];
	[super dealloc];
}
@end
