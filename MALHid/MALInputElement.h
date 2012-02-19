//
//  MALInputElement.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidStructs.h"

@interface MALInputElement : NSObject {
	NSMutableArray * observers;
	
	// does this provide enough to deliniate between different types? 0D, 1D, 2D, 3D
	int value,min,max;
	
	MALHidUsage hidUsage;
	
	int isRelative:1;
	
	// timestamp of new, of last
	// flag for if it is raw (i.e. not the best representation (e.g. hatswitch))
}

-(MALHidUsage) usage;
-(NSString*) path;
@end
