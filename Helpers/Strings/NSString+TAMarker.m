//
//  NSString+TAMarker.m
//  Helpers
//
//  Created by Thomas Abplanalp on 27.04.17.
//	  Copyright © 2017 TASoft Applications. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

#import "NSString+TAMarker.h"

// NSValue containing the failed marker range in the original string
NSString const *TAMarkerOriginalRangeErrorKey = @"TAMarkerOriginalRangeErrorKey";

// NSValue containing the failed marker range in the resolved string.
NSString const *TAMarkerResolvedRangeErrorKey = @"TAMarkerResolvedRangeErrorKey";

// NSString containing the name of the marker that issue the recursion.
NSString const *TAMarkerNameErrorKey = @"TAMarkerNameErrorKey";

// NSArray list with marker stack until failed marker.
NSString const *TAMarkerTraceErrorKey = @"TAMarkerTraceErrorKey";


@implementation NSString (TAMarker)
- (BOOL)hasMarkers {
	return [self rangeOfString:@"$("].location < NSNotFound ? YES : NO;
}

- (NSString *_Nonnull)stringByResolvingMarkersUsingBlock:(NSString *_Nullable(^_Nullable)(NSString * _Nonnull marker))block {
	if([self hasMarkers] == NO)
		return self;
	
	NSArray *datas = [self componentsSeparatedByString:@"$("];
	NSMutableString *fin = [NSMutableString stringWithString:datas[0]];
	
	if(datas.count>1) {
		for(int e=1;e<datas.count;e++) {
			NSString *line = datas[e];
			NSRange search = [line rangeOfString:@")"];
			if(search.location < NSNotFound) {
				NSString *key = [line substringToIndex:search.location];
				line = [line substringFromIndex:search.location+1];
				
				NSString *sub = block(key);
				if(sub)
					[fin appendString:sub];
				else {
					[fin appendString:[NSString stringWithFormat:@"$(%@)", key]];
				}
			}
			[fin appendString:line];
		}
	}
	
	return fin;
}

- (NSString *)stringByResolvingMarkersUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary {
	return [self stringByResolvingMarkersUsingBlock:^NSString *(NSString *  marker) {
		return dictionary[marker];
	}];
}

- (NSString *)stringByResolvingMarkersRecursiveUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary
														error:(NSError * *)error {
	return [self stringByResolvingMarkersRecursiveUsingBlock:^NSString * (NSString *  marker) {
		return dictionary[marker];
	} error:error];
}


- (NSString *_Nonnull)_stringByResolvingMarkersUsingBlock:(NSString *_Nullable(^_Nullable)(NSString * _Nonnull marker))block
													error:(NSError *_Nullable*_Nullable)error
													trace:(NSArray **)trace
										   recursionStack:(NSArray *)items
											   failedItem:(NSString **)itemName {
	if([self hasMarkers] == NO)
		return self;
	
	NSString *resolved = [self stringByResolvingMarkersUsingBlock:^NSString * _Nullable(NSString * _Nonnull marker) {
		if(*itemName)
			return nil;
		NSArray *currentStack = [items arrayByAddingObject:marker];
		
		if([items containsObject:marker]) {
			*itemName = marker;
			*trace = currentStack;
			return nil;
		}
		
		
		NSString *newString = block(marker);
		
		if([newString hasMarkers]) {
			newString = [newString _stringByResolvingMarkersUsingBlock:block error:error trace:trace recursionStack:currentStack failedItem:itemName];
		}
		
		return newString;
	}];
	
	return resolved;
}


- (NSString *_Nonnull)stringByResolvingMarkersRecursiveUsingBlock:(NSString *_Nullable(^_Nullable)(NSString * _Nonnull marker))block
												   error:(NSError *_Nullable*_Nullable)error {
	NSArray *stack = nil;
	NSString *failedItem = nil;
	NSString *string = [self _stringByResolvingMarkersUsingBlock:block error:error trace:&stack recursionStack:@[] failedItem:&failedItem];
	if(failedItem) {
		if(error) {
			NSMutableDictionary *errorDesc = [NSMutableDictionary dictionary];
			errorDesc[NSLocalizedDescriptionKey] = @"Recursion";
			errorDesc[NSLocalizedFailureReasonErrorKey] = errorDesc[NSLocalizedRecoverySuggestionErrorKey] = [NSString stringWithFormat:@"Marker %@ is referencing itself.", failedItem];
			
			NSString *marker = [NSString stringWithFormat:@"$(%@)", failedItem];
			errorDesc[TAMarkerOriginalRangeErrorKey] = [NSValue valueWithRange:[self rangeOfString:marker]];
			errorDesc[TAMarkerResolvedRangeErrorKey] = [NSValue valueWithRange:[string rangeOfString:marker]];
			errorDesc[TAMarkerNameErrorKey] = failedItem;
			if(stack)
				errorDesc[TAMarkerTraceErrorKey] = stack;
			
			*error = [NSError errorWithDomain:@"ch.tasoft.string.marker" code:102 userInfo:errorDesc];
		}
	}
	
	return string;
}

- (NSString*)_debug:(NSString *(^)(NSString *  marker))block
		 stack:(NSArray *)items
		 depth:(NSUInteger)depth {
	if([self hasMarkers] == NO)
		return self;
	
	void(^printIndention)() =^{
		for(int e=0;e<depth;e++)
			printf("    ");
	};
	
	NSString *resolved = [self stringByResolvingMarkersUsingBlock:^NSString * _Nullable(NSString * _Nonnull marker) {
		printIndention();
		printf("MARKER  : %s\n", [marker UTF8String]);
		printIndention();
		printf("RESOLVED: ");
		
		NSArray *currentStack = [items arrayByAddingObject:marker];
		
		
		if([items containsObject:marker]) {
			printf("#Recursion! :: %s\n", [[currentStack componentsJoinedByString:@" -> "] UTF8String]);
			printf("---------------------------------------------------\n");
			return nil;
		}
		
		NSString *newString = block(marker);
		if(newString)
			printf("%s\n", [newString UTF8String]);
		else
			printf("#Not Found.\n");
		printf("---------------------------------------------------\n");
		
		if([newString hasMarkers])
			newString = [newString _debug:block stack:currentStack depth:depth+1];
		
		return newString;
	}];
	
	return resolved;
}

- (void)printResolvingReportUsingBlock:(NSString *(^)(NSString *  marker))block {
	printf("Debug String: `%s`\n", [self UTF8String]);
	NSString *result = [self _debug:block stack:@[] depth:1];
	printf("======= RESULT =====\n%s\n===================\n", [result UTF8String]);
}

- (void)printResolvingReportUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary {
	[self printResolvingReportUsingBlock:^NSString *(NSString *marker) {
		return dictionary[marker];
	}];
}
@end
