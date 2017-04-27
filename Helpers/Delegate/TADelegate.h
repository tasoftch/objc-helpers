//
//  TADelegate.h
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

#import <Foundation/Foundation.h>

// This macro forces that a delegate is set and it implements the required selector SELECTOR.
// This macro returns a value, if anything went well.
// If not, it throws an exception. But the compiler will not accept an assignment from a (void) call.
// So that's why this macro appears with several return types.
// Use this TARequiredDelegate for object assignment
#define TARequiredDelegate(DELEGATE, SELECTOR, METHOD) \
	[DELEGATE respondsToSelector:@selector(SELECTOR)] ?\
	[DELEGATE METHOD] :\
	_TADelegateNotifyID(DELEGATE, @#SELECTOR)
id _TADelegateNotifyID(id obj, NSString *selector);

// Use TARequiredDelegateB for boolean assignments
#define TARequiredDelegateB(DELEGATE, SELECTOR, METHOD) \
[DELEGATE respondsToSelector:@selector(SELECTOR)] ?\
[DELEGATE METHOD] :\
_TADelegateNotifyBool(DELEGATE, @#SELECTOR)
bool _TADelegateNotifyBool(id obj, NSString *selector);

// Use TARequiredDelegateD for doubles assignments
#define TARequiredDelegateD(DELEGATE, SELECTOR, METHOD) \
[DELEGATE respondsToSelector:@selector(SELECTOR)] ?\
[DELEGATE METHOD] :\
_TADelegateNotifyDouble(DELEGATE, @#SELECTOR)
double _TADelegateNotifyDouble(id obj, NSString *selector);

// Use TARequiredDelegateI for integer assignments
#define TARequiredDelegateI(DELEGATE, SELECTOR, METHOD) \
[DELEGATE respondsToSelector:@selector(SELECTOR)] ?\
[DELEGATE METHOD] :\
_TADelegateNotifyInt(DELEGATE, @#SELECTOR)
int _TADelegateNotifyInt(id obj, NSString *selector);


// Requires a value from a assigned delegate. If the delegate is nil,
// it returns the default value. But if the delegate does not implement
// the required method, it will throw an exception.
#define TARequiredDelegateWithNil(DELEGATE, SELECTOR, METHOD, DEFAULT) \
	((DELEGATE) ? ( TARequiredDelegate(DELEGATE, SELECTOR, METHOD) ) : DEFAULT )

// Retrieves an optional value from delegate
#define TAOptionalDelegate(DELEGATE, SELECTOR, METHOD, DEFAULT) \
	[DELEGATE respondsToSelector:@selector(SELECTOR)] ?\
	[DELEGATE METHOD] :\
	DEFAULT

// Ensures, that a given code is performed synchron in main thread
#define TAPerformInMainThread(CodeBlock)\
if([NSThread isMainThread]) {\
	CodeBlock\
}\
else {\
	dispatch_sync(dispatch_get_main_queue(), ^{\
		CodeBlock\
	});\
}
