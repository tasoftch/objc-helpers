//
//  HelpersTests.m
//  HelpersTests
//
//  Created by Thomas Abplanalp on 27.04.17.
//  Copyright © 2017 TASoft Applications. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+TAMarker.h"
static NSDictionary *generalMarkers = nil;

@interface HelpersTests : XCTestCase

@end

@implementation HelpersTests

- (void)setUp {
    [super setUp];
	
	
	if(!generalMarkers)
		generalMarkers = @{
							   @"HELLO": @"World!",
							   @"TEST": @"Was $(HELLO)",
							   @"MAL":@"LAS $(HELLO)",
							   @"QUR":@"MIR $(TEST)",
							   @"T3":@"NAWH $(QUR)",
							   @"REQ": @"HAM $(T3) und $(REQ3)",
							   @"REQ2": @"LOTH $(REQ)",
							   @"REQ3":@"MANS $(REQ)",
							   @"UNK": @"Refers to $(UNKNOWN)"
							   };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGeneralStringMarkersOneLevel {
	NSString *result = [@"Hello $(HELLO)" stringByResolvingMarkersUsingDictionary:generalMarkers];
	XCTAssertEqualObjects(@"Hello World!", result);
	
	result = [@"Hello $(TEST)" stringByResolvingMarkersUsingDictionary:generalMarkers];
	XCTAssertEqualObjects(@"Hello Was $(HELLO)", result);
	
	result = [@"Hello $(UNK)" stringByResolvingMarkersUsingDictionary:generalMarkers];
	XCTAssertEqualObjects(@"Hello Refers to $(UNKNOWN)", result);
	
	result = [@"Hello $(REQ)" stringByResolvingMarkersUsingDictionary:generalMarkers];
	XCTAssertEqualObjects(@"Hello HAM $(T3) und $(REQ3)", result);
}

- (void)testRepeatlyMarkersOneLevel {
	NSString *result = [@"Hello $(HELLO) $(HELLO)" stringByResolvingMarkersUsingDictionary:generalMarkers];
	XCTAssertEqualObjects(@"Hello World! World!", result);
}

- (void)testRecursiveMarkers {
	NSError *error = nil;
	NSString *result = [@"Hello $(T3)" stringByResolvingMarkersRecursiveUsingDictionary:generalMarkers error:&error];
	XCTAssertEqualObjects(@"Hello NAWH MIR Was World!", result);
	XCTAssertNil(error);
}

- (void)testRecursiveMarkersRepeatly {
	NSError *error = nil;
	NSString *result = [@"Hello $(T3) $(HELLO) $(HELLO)" stringByResolvingMarkersRecursiveUsingDictionary:generalMarkers error:&error];
	XCTAssertEqualObjects(@"Hello NAWH MIR Was World! World! World!", result);
	XCTAssertNil(error);
}

- (void)testRecursiveMarkersRepeatlyNonRecursive {
	NSError *error = nil;
	NSString *result = [@"Hello $(T3) $(HELLO) $(MAL)" stringByResolvingMarkersRecursiveUsingDictionary:generalMarkers error:&error];
	XCTAssertEqualObjects(@"Hello NAWH MIR Was World! World! LAS World!", result);
	XCTAssertNil(error);
}

- (void)testRecursiveMarkersWithRecursion {
	NSError *error = nil;
	NSString *result = [@"Hello $(REQ)" stringByResolvingMarkersRecursiveUsingDictionary:generalMarkers error:&error];
	XCTAssertEqualObjects(@"Hello HAM NAWH MIR Was World! und MANS $(REQ)", result);
	XCTAssertNotNil(error);
	XCTAssertEqualObjects(@"REQ", [error.userInfo objectForKey:@""]);
}

@end
