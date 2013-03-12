//
//  MALInputElement.m
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALHidInternal.h"

@implementation MALInputElement
-(MALHidUsage) usage {
	if(hidUsage.page == 0 && hidUsage.ID == 0) printf("---------------------\n");
	return hidUsage;}

-(void) setPath:(NSString*)p {
	if(path) [[MALInputCenter shared] removeInputAtPath:path];
	
	path = [p copy];
	
	[[MALInputCenter shared] addInput:self atPath:path];
}

-(void) updateValue:(int)value timestamp:(uint64_t)t {
	[[MALInputCenter shared] valueChanged:self path:path];
}

-(NSString*) pathOfType:(MALInputPathType)type {return nil;}
-(NSString*) path {return nil;}

-(BOOL) isScalar {return (max-min) > 1;}
@end
