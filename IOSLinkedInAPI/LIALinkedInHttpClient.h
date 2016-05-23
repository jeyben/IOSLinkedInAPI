// LIALinkedInHttpClient.h
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

/**
 *  Check if before AFNetworking 3.0
 */
#if __has_include_next("AFNetworking/AFHTTPRequestOperationManager.h")

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#define AFHTTPManager AFHTTPRequestOperationManager

#elif __has_include_next("AFNetworking/AFHTTPSessionManager.h")

#import <AFNetworking/AFHTTPSessionManager.h>
#define AFHTTPManager AFHTTPSessionManager
#define isSessionManager 1

#endif

@class LIALinkedInApplication;

/**
 * A LinkedIn client is created using a `LIALinkedInApplication` and is the network instance that will perform all requests to the LinkedIn API.
 **/
@interface LIALinkedInHttpClient : AFHTTPManager

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * A LinkedIn client is created using a `LIALinkedInApplication` and is the network instance that will perform all requests to the LinkedIn API.
 * @param application A `LIALinkedInApplication` configured instance.
 * @discussion This method calls `+clientForApplication:presentingViewController:` with presenting view controller as nil.
 **/
+ (LIALinkedInHttpClient *)clientForApplication:(LIALinkedInApplication *)application;

/**
 * A LinkedIn client is created using a `LIALinkedInApplication` and is the network instance that will perform all requests to the LinkedIn API.
 * @param application A `LIALinkedInApplication` configured instance.
 * @param viewController The view controller that the UIWebView will be modally presented from. Passing nil assumes the root view controller.
 **/
+ (LIALinkedInHttpClient *)clientForApplication:(LIALinkedInApplication *)application presentingViewController:viewController;

/** ************************************************************************************************ **
 * @name Methods
 ** ************************************************************************************************ **/

/**
 * Returns YES if the current cached token is valid and not expired, NO otherwise.
 * @return The validity of the cached token.
 * @discussion When getting the token via the method `-getAccessToken:success:failure:`, the library is caching the token for further use.
 **/
- (BOOL)validToken;

/**
 * Returns the previsouldy cached LinkedIn access token.
 * @return The access token.
 * @discussion When getting the token via the method `-getAccessToken:success:failure:`, the library is caching the token for further use.
 **/
- (NSString *)accessToken;

/**
 * Retrieves the access token from a valid authhorization code.
 * @param authorizationCode The authorization code.
 * @param success A success block. The success block contains a dictoinary containing the access token keyed by the string "access_token".
 * @param failure A failure block containing the error.
 **/
- (void)getAccessToken:(NSString *)authorizationCode success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;

/**
 * Retrieves an authorization code.
 * @param success A success block.
 * @param cancel A cancel block. This block is called when the user cancels the linkedin authentication flow.
 * @param failure A failure block containing the error.
 **/
- (void)getAuthorizationCode:(void (^)(NSString *))success cancel:(void (^)(void))cancel failure:(void (^)(NSError *))failure;

@end
