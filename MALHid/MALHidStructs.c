//
//  MALHidStructs.c
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "MALHidStructs.h"

MALHidUsage MakeMALHidUsage(unsigned page, unsigned ID) {
	MALHidUsage usage = {page, ID};
	return usage;
}