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

@end
