//
//  MALOutputElement.m
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import "MALInputPrivate.h"

@implementation MALOutputElement

+(MALOutputElement*) boolElement {
	MALOutputElement *e = [[self alloc] init];
	e->rawMin=0; e->rawMax = 1;
	return [e autorelease];
}

@end
