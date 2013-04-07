//
//  MALInputDevice.m
//  MALHid
//
//  Created by Rovolo on 4/4/13.
//
//

#import "MALIODevice.h"

@implementation MALIODevice
@synthesize location, elements, name, deviceID;

-(BOOL) isSpecific {
	return location != 0;
}

-(void) setElement:(MALIOElement*)element forPath:(NSString*)path {
	[elements setObject:element forKey:path];
	if([self isSpecific])
		element.specificDevice = self;
	else
		element.generalDevice = self;
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

+(MALIODevice*) device{
	MALIODevice * d = [[MALIODevice alloc] init];
	return [d autorelease];
}
+(MALHidUsage) usageForDevice:(IOHIDDeviceRef)device {
	int usagePage = [getHIDDeviceProperty(device, kIOHIDPrimaryUsagePageKey) intValue];
	int usageID = [getHIDDeviceProperty(device, kIOHIDPrimaryUsageKey) intValue];
	return MakeMALHidUsage(usagePage, usageID);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@, %@",self.deviceID,self.elements];
}
-(void) dealloc {
	[elements release]; elements=nil;
	[super dealloc];
}
@end

