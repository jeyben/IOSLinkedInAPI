// LIALinkedInApplication.h
//
// Copyright (c) 2013 Ancientprogramming
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>

/**
 * A LIALinkedInApplication defines the application which is granted access to the users linkedin data.
 **/
@interface LIALinkedInApplication : NSObject

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * The default initializer.
 * @param redirectURL Has to be a http or https url (required by LinkedIn), but other than that, the endpoint doesn't have to respond anything. The library only uses the endpoint to know when to intercept calls in the UIWebView.
 * @param clientId The id which is provided by LinkedIn upon registering an application.
 * @param clientSecret The secret which is provided by LinkedIn upon registering an application.
 * @param state The state used to prevent Cross Site Request Forgery. Should be something that is hard to guess.
 * @param grantedAccess An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication.
 * @return An initialized instance.
 **/
- (id)initWithRedirectURL:(NSString *)redirectURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret state:(NSString *)state grantedAccess:(NSArray *)grantedAccess;

/**
 * The default static initializer.
 * @param redirectURL Has to be a http or https url (required by LinkedIn), but other than that, the endpoint doesn't have to respond anything. The library only uses the endpoint to know when to intercept calls in the UIWebView.
 * @param clientId The id which is provided by LinkedIn upon registering an application.
 * @param clientSecret The secret which is provided by LinkedIn upon registering an application.
 * @param state The state used to prevent Cross Site Request Forgery. Should be something that is hard to guess.
 * @param grantedAccess An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication.
 * @return An initialized instance.
 **/
+ (id)applicationWithRedirectURL:(NSString *)redirectURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret state:(NSString *)state grantedAccess:(NSArray *)grantedAccess;

/** ************************************************************************************************ **
 * @name Attributes
 ** ************************************************************************************************ **/

/**
 * Has to be a http or https url (required by LinkedIn), but other than that, the endpoint doesn't have to respond anything. The library only uses the endpoint to know when to intercept calls in the UIWebView.
 **/
@property(nonatomic, copy) NSString *redirectURL;

/**
 * The id which is provided by LinkedIn upon registering an application.
 **/
@property(nonatomic, copy) NSString *clientId;

/**
 * The secret which is provided by LinkedIn upon registering an application.
 **/
@property(nonatomic, copy) NSString *clientSecret;

/**
 * The state used to prevent Cross Site Request Forgery. Should be something that is hard to guess.
 **/
@property(nonatomic, copy) NSString *state;

/**
 * An array telling which access the application would like to be granted by the enduser. See full list here: http://developer.linkedin.com/documents/authentication.
 **/
@property(nonatomic, strong) NSArray *grantedAccess;

/** ************************************************************************************************ **
 * @name Methods
 ** ************************************************************************************************ **/

/**
 * Returns a string composed of the `grantedAccess` parameters.
 * @return All granted access parameters in a string.
 **/
- (NSString *)grantedAccessString;

@end