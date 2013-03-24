//
//  MALInputProfile.h
//  MALHid
//
//  Created by Rovolo on 3/23/13.
//
//

#import <Foundation/Foundation.h>

@class MALInputElement,MALOutputElement;

@interface MALInputProfile : NSObject <NSCopying> {
	NSMutableDictionary * inputs,*outputs;
}
@property (readonly) NSDictionary *inputs,*outputs;
-(void) setOutput:(MALOutputElement*)e forKey:(NSString*)key;
-(void) setInput:(MALInputElement*)e forKey:(NSString*)key;
-(MALOutputElement*) outputElementForKey:(NSString*)key;
-(MALInputElement*) inputElementForKey:(NSString*)key;

-(NSSet*) allKeys;
-(NSDictionary*) bindingsByID;
@end
