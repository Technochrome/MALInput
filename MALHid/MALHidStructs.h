//
//  MALHidStructs.h
//  MALHid
//
//  Created by Rovolo on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MALHid_MALHidStructs_h
#define MALHid_MALHidStructs_h

typedef struct {
	unsigned page,ID;
} MALHidUsage;

MALHidUsage MakeMALHidUsage(unsigned page, unsigned ID);


#endif
