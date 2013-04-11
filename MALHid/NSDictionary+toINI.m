//
//  NSDictionary+toINI.m
//  MALHid
//
//  Created by Rovolo on 4/7/13.
//
//

#import "NSDictionary+toINI.h"

@implementation NSDictionary (toINI)
-(NSString*) _toINI:(BOOL)isSublevel {
	NSMutableString * output = [NSMutableString string];
	for (id key in [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 caseInsensitiveCompare:obj2];
	}]) {
		id obj = self[key];
		
		if(!isSublevel && [obj isKindOfClass:[NSDictionary class]]) {
			[output appendFormat:@"[%@]\n%@\n",key, [obj toINI]];
		} else {
			[output appendFormat:@"%@=%@\n",key, obj];
		}
	}
	return output;
}
-(NSString*) toINI {
	return [self _toINI:NO];
}
+(NSDictionary*) dictionaryWithINI:(NSString*)ini {
	__block NSMutableDictionary * dict = [NSMutableDictionary dictionary], *currTarget = dict;
	[ini enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		if([line hasPrefix:@"["]) {
			currTarget = [NSMutableDictionary dictionary];
			[dict setObject:currTarget forKey:[line substringWithRange:NSMakeRange(1, [line length]-2)]];
		} else if([line length] >0) {
			NSRange idx = [line rangeOfString:@"="];
			if(idx.location != NSNotFound)
			[currTarget setObject:[line substringFromIndex:idx.location+1]
						   forKey:[line substringToIndex:idx.location]];
		}
	}];
	return dict;
}
@end
