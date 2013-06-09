//
//  NSString+LIAEncode.m
//  Sheep or Pig
//
//  Created by Eugene on 04/06/2013.
//  Copyright (c) 2013 StocksCompare. All rights reserved.
//

#import "NSString+LIAEncode.h"

@implementation NSString (LIAEncode)

-(NSString *) LIAEncode {
	return (NSString *)CFBridgingRelease(
		CFURLCreateStringByAddingPercentEscapes(
			NULL,
			(__bridge CFStringRef) self,
			NULL,
			CFSTR("!*'();:@&=+$,/?%#[]"),
			kCFStringEncodingUTF8
			)
		);
}

@end
