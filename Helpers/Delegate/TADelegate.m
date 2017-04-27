//
//  TADelegate.m
//  Settings List With Configurations
//
//  Created by Thomas Abplanalp on 26.04.17.
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

#import "TADelegate.h"

id _TADelegateNotifyID(id obj, NSString *selector) {
	[NSException raise:@"ch.tasoft.delegate" format:@"%@ does not implement required method %@.", obj, selector];
	return nil;
}

// Helper functions to map a forced delegate call according to assignments.
bool _TADelegateNotifyBool(id obj, NSString *selector) {
	_TADelegateNotifyID(obj, selector);
	return false;
}

double _TADelegateNotifyDouble(id obj, NSString *selector)  {
	_TADelegateNotifyID(obj, selector);
	return 0;
}

int _TADelegateNotifyInt(id obj, NSString *selector)  {
	_TADelegateNotifyID(obj, selector);
	return 0;
}

