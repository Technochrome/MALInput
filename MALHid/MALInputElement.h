//
//  MALInputElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidStructs.h"
#import "MALIOElement.h"

@class MALInputElement;

@interface MALInputElement : MALIOElement {
	NSString * path;
	MALHidUsage hidUsage;
}
@property (readonly) MALHidUsage usage;
@property (readwrite,copy,nonatomic) NSString * path;


// Somehow look at history

-(NSString*) controllerName;
-(NSString*) inputName;
@end
