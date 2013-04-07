//
//  MALInputDevice.h
//  MALHid
//
//  Created by Rovolo on 4/4/13.
//
//

#import <Foundation/Foundation.h>

#import "MALHidStructs.h"
#import "MALHidInternal.h"


@interface MALIODevice : NSObject
@property (readwrite) int location;
@property (readwrite,copy) NSString * name, *deviceID;
@property (readonly) NSString * path, *devicePath;
@property (readonly) NSMutableDictionary * elements;
@property (readonly) BOOL isSpecific;

-(void) setElement:(MALIOElement*)element forPath:(NSString*)path;

+(MALIODevice*) device;
+(MALHidUsage) usageForDevice:(IOHIDDeviceRef)device;
@end
