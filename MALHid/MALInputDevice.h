//
//  MALInputDevice.h
//  MALHid
//
//  Created by Rovolo on 4/4/13.
//
//

#import "MALInput.h"


@class MALIOElement;

@interface MALInputDevice : NSObject
@property (readwrite) int location;
@property (readwrite,copy) NSString * name, *deviceID;
@property (readonly) NSString *devicePath;
@property (readonly) NSMutableDictionary * elements;
@property (readonly) BOOL isSpecific;

-(BOOL) setElement:(MALIOElement*)element forPath:(NSString*)path;

+(MALInputDevice*) device;
@end