//
//  MALInputDevice.m
//  MALHid
//
//  Created by Rovolo on 4/4/13.
//
//

#import "MALInputPrivate.h"

@implementation MALInputDevice
@synthesize location, elements, name, deviceID;

-(BOOL) isSpecific {
	return location != 0;
}

-(BOOL) setElement:(MALIOElement*)element forPath:(NSString*)path {
	if([elements objectForKey:path]!=nil) return NO;
	
	[elements setObject:element forKey:path];
	if([self isSpecific])
		element.specificDevice = self;
	else
		element.generalDevice = self;
	
	return YES;
}

-(NSString*) devicePath {
	return [NSString stringWithFormat:@"%@#%x",deviceID,location];
}

-(id) init {
	if((self = [super init])) {
		elements = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+(MALInputDevice*) device{
	MALInputDevice * d = [[MALInputDevice alloc] init];
	return [d autorelease];
}
+(MALHidUsage) usageForDevice:(IOHIDDeviceRef)device {
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	return MakeMALHidUsage(usagePage, usageID);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"<%@(%p) %@>",[self class],self,self.devicePath];
}
-(void) dealloc {
	[elements release]; elements=nil;
	[super dealloc];
}
@end

