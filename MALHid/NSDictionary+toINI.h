//
//  NSDictionary+toINI.h
//  MALHid
//
//  Created by Rovolo on 4/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (toINI)
-(NSString*) toINI;
+(NSDictionary*) dictionaryWithINI:(NSString*)ini;
@end
