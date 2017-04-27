//
//  NSString+TAMarker.h
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

#import <Foundation/Foundation.h>


// This category handles markers in strings. A marker is a string with this pattern: $(MARKER_NAME)
// It is recommended to unly use alpha-nummeric marker names.
// The resolution of a marker may contain other markers. To resolve them completely use the *Recursive* methods.
@interface NSString (TAMarker)

// Checks, if a string contains markers
- (BOOL)hasMarkers;

// Resolves one level markers. If a marker contains other markers, they will be igrored.
- (NSString *)stringByResolvingMarkersUsingBlock:(NSString *(^)(NSString *  marker))block NS_AVAILABLE(10_6, 4_0);

// Same as with blocks but uses a dictionary instead.
- (NSString *)stringByResolvingMarkersUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary;

// Recursively resolution of markers. It will resolve each marker until its resolution does not produce more markers.
// The execution stops, if there is a recursion and a detailed error report is registered.
// If a recursion error occures, it stops the interpolation of further markers.
- (NSString *)stringByResolvingMarkersRecursiveUsingBlock:(NSString *(^)(NSString *  marker))block error:(NSError **)error NS_AVAILABLE(10_6, 4_0);

// Same mechanism but taking marker contents from a dictionary.
- (NSString *)stringByResolvingMarkersRecursiveUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary error:(NSError * *)error;

// Debugging
- (void)printResolvingReportUsingBlock:(NSString *(^)(NSString *  marker))block;
- (void)printResolvingReportUsingDictionary:(NSDictionary <NSString*,NSString*> *)dictionary;
@end


// If an error occures, the user info of the error object may contain the following keys

// NSValue containing the failed marker range in the original string
extern NSString const *TAMarkerOriginalRangeErrorKey;

// NSValue containing the failed marker range in the resolved string.
extern NSString const *TAMarkerResolvedRangeErrorKey;

// NSString containing the name of the marker that issue the recursion.
extern NSString const *TAMarkerNameErrorKey;

// NSArray list with marker stack until failed marker.
extern NSString const *TAMarkerTraceErrorKey;

