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
													error:(NSError *_Nullable*_Nullable)error trace:(NSMutableArray *)trace
										   recursionStack:(NSArray *)items
											   failedItem:(NSString **)itemName {
	if([self hasMarkers] == NO)
		return self;
	
	NSMutableArray *currentStack = items.mutableCopy;
	NSString *resolved = [self stringByResolvingMarkersUsingBlock:^NSString * _Nullable(NSString * _Nonnull marker) {
		if(*itemName)
			return nil;
		
		if([items containsObject:marker]) {
			*itemName = marker;
			return nil;
		}
		
		[currentStack addObject:marker];
		
		NSString *newString = block(marker);
		
		if([newString hasMarkers]) {
			NSMutableDictionary *newTrace = [NSMutableDictionary dictionary];
			newTrace[@"1. MARKER"] = marker;
			newTrace[@"2. STRING"] = newString;
			NSMutableArray *nextStack = [NSMutableArray array];
			newTrace[@"3. NEXT"] = nextStack;
			[trace addObject:newTrace];
			
			
			newString = [newString _stringByResolvingMarkersUsingBlock:block error:error trace:nextStack recursionStack:currentStack failedItem:itemName];
		}
		
		return newString;
	}];
	
	return resolved;
}


- (NSString *_Nonnull)stringByResolvingMarkersUsingBlock:(NSString *_Nullable(^_Nullable)(NSString * _Nonnull marker))block
												   error:(NSError *_Nullable*_Nullable)error {
	NSMutableArray *trace = @[].mutableCopy;
	NSString *failedItem = nil;
	NSString *string = [self _stringByResolvingMarkersUsingBlock:block error:error trace:trace recursionStack:@[] failedItem:&failedItem];
	if(failedItem) {
		if(error) {
			NSMutableDictionary *errorDesc = [NSMutableDictionary dictionary];
			errorDesc[NSLocalizedDescriptionKey] = @"Recursion";
			errorDesc[NSLocalizedFailureReasonErrorKey] = errorDesc[NSLocalizedRecoverySuggestionErrorKey] = [NSString stringWithFormat:@"Marker %@ is referencing itself.", failedItem];
			
			NSString *marker = [NSString stringWithFormat:@"$(%@)", failedItem];
			errorDesc[@"TAOriginalErrorRange"] = [NSValue valueWithRange:[self rangeOfString:marker]];
			errorDesc[@"TAResolvedErrorRange"] = [NSValue valueWithRange:[string rangeOfString:marker]];
			errorDesc[@"TAMarkerName"] = failedItem;
			errorDesc[@"TAMarkerTrace"] = trace;
			
			*error = [NSError errorWithDomain:@"ch.tasoft.string.marker" code:102 userInfo:errorDesc];
		}
	}
	
	return string;
}
@end
