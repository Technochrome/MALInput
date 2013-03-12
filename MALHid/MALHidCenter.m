//
//  MALHid.c
//  MALHid
//
//  Created by Rovolo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

#pragma mark Implementations
@implementation MALHidCenter
+(MALHidCenter *) shared {
	static MALHidCenter * shared = nil;
	if(!shared) shared = [[self alloc] init];
	return shared;
}
-(BOOL) addObserver:(MALHidElement*)o forElement:(IOHIDElementRef)e {
	if(!o) return NO;
	NSString * key = [MALHidElement keyForElement:e];
	if([rawValueDict objectForKey:key]) return NO;
	[rawValueDict setObject:o forKey:key];
	return YES;
}
-(void) removeObserver:(MALHidElement*)o {
	for(id key in [rawValueDict allKeysForObject:o])
		[rawValueDict removeObjectForKey:key];
}
-(NSString *) descriptionForPage:(unsigned) usagePage usage:(unsigned) usage {

	NSString * usagePageString = [NSString stringWithFormat: @"%u", usagePage];
	NSString * usageString = [NSString stringWithFormat: @"%u", usage];

	NSDictionary * usagePageLookup = [mLookupTables objectForKey: usagePageString];
	if (usagePageLookup == nil)
		return [NSString stringWithFormat:@"Unknown usage page %u,%u",usagePage,usage];

	NSDictionary * usageLookup = [usagePageLookup objectForKey: @"usages"];
	NSString * description = [usageLookup objectForKey: usageString];
	if (description != nil)
		return description;

	// Buttons for instance don't have descriptions for each ID, default = @"button %d"
	NSString * defaultUsage = [usagePageLookup objectForKey: @"default"];
	if (defaultUsage != nil) {
		description = [NSString stringWithFormat: defaultUsage, usage];
		return description;
	}

	return @"Unknown usage";
}
-(id) init {
	self = [super init]; if(!self) return nil;
	
	NSBundle * myBundle = [NSBundle bundleForClass:[MALHidCenter class]];
	NSString * usageTablesPath = [myBundle pathForResource: @"DDHidStandardUsages" ofType: @"plist"];
	mLookupTables = [[NSDictionary dictionaryWithContentsOfFile: usageTablesPath] retain];
	
	rawValueDict = [[NSMutableDictionary alloc] init];
	
	return self;
}

-(void) newValue:(IOHIDValueRef)value {
	NSString * key = [MALHidElement keyForElement:IOHIDValueGetElement(value)];
	MALHidElement * ob = [rawValueDict objectForKey:key];
	[ob valueChanged:value];
}
@end