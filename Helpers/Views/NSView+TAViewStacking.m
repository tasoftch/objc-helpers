//
//  NSView+TAViewStacking.m
//  CDO Camp Planer X
//
//  Created by Thomas Abplanalp on 25/09/16.
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

#import "NSView+TAViewStacking.h"

@implementation NSView (TAViewStacking)
- (void)_removeAllSubviews:(BOOL)flag {
	while (self.subviews.count) {
		[[self.subviews lastObject] removeFromSuperviewWithoutNeedingDisplay];
	}
	if(flag)
		[self setNeedsDisplay:YES];
}

- (void)removeAllSubviews {
	[self _removeAllSubviews:YES];
}

- (void)removeAllSubviewsWithoutNeedingDisplay {
	[self _removeAllSubviews:NO];
}

- (void)setContentView:(NSView *)view {
	[self removeAllSubviewsWithoutNeedingDisplay];
	if(view) {
		view.translatesAutoresizingMaskIntoConstraints = NO;
		self.translatesAutoresizingMaskIntoConstraints = NO;
		
		[self addSubview:view];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:Nil views:@{@"view":view}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:Nil views:@{@"view":view}]];
	}
	else
		[self setNeedsDisplay:YES];
}
@end
