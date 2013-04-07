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
	MALHidUsage hidUsage;
}
@property (readonly) MALHidUsage usage;
@property (readwrite, copy) NSString *elementID;
@property (readonly) NSString *fullID,*specificPath,*generalPath;

// Somehow look at history

-(NSString*) controllerName;
-(NSString*) inputName;
@end
