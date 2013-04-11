//
//  MALInputElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@implementation MALInputElement
@synthesize usage=hidUsage,elementID;

-(id) init {
	if((self = [super init])) {
	} return self;
}
-(void) updateValue:(long)newValue timestamp:(uint64_t)t {
	[super updateValue:newValue timestamp:t];
	if(isDiscoverable) [[MALInputCenter shared] valueChanged:self];
}
-(NSString*) fullID {
	return [NSString stringWithFormat:@"%@~%@", generalDevice.deviceID, self.elementID];
}
-(NSString*) specificPath {
	return [NSString stringWithFormat:@"%@~%@", specificDevice.devicePath, self.elementID];
}
-(NSString*) generalPath {
	return [NSString stringWithFormat:@"%@~%@", generalDevice.devicePath, self.elementID];
}
+(NSString*) deviceIDFromFullID:(NSString*)fullID {
	return [fullID componentsSeparatedByString:@"~"][0];
}
+(NSString*) elementIDFromFullID:(NSString*)fullID {
	return [fullID componentsSeparatedByString:@"~"][1];
}
-(NSString*) controllerName {
	return @"No controller name";
}
-(NSString*) inputName {
	return @"No input name";
}
@end
