// LIALinkedInAuthorizationViewController.m
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
#import "LIALinkedInAuthorizationViewController.h"
#import "NSString+LIAEncode.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString *kLinkedInErrorDomain = @"LIALinkedInERROR";
NSString *kLinkedInDeniedByUser = @"the+user+denied+your+request";

@interface LIALinkedInAuthorizationViewController ()
@property(nonatomic, strong) UIWebView *authenticationWebView;
@property(nonatomic, copy) LIAAuthorizationCodeFailureCallback failureCallback;
@property(nonatomic, copy) LIAAuthorizationCodeSuccessCallback successCallback;
@property(nonatomic, copy) LIAAuthorizationCodeCancelCallback cancelCallback;
@property(nonatomic, strong) LIALinkedInApplication *application;
@end

@interface LIALinkedInAuthorizationViewController (UIWebViewDelegate) <UIWebViewDelegate>

@end

@implementation LIALinkedInAuthorizationViewController

BOOL handlingRedirectURL;

- (id)initWithApplication:(LIALinkedInApplication *)application success:(LIAAuthorizationCodeSuccessCallback)success cancel:(LIAAuthorizationCodeCancelCallback)cancel failure:(LIAAuthorizationCodeFailureCallback)failure {
    self = [super init];
    if (self) {
        self.application = application;
        self.successCallback = success;
        self.cancelCallback = cancel;
        self.failureCallback = failure;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
		
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancelButton:)];
	self.navigationItem.leftBarButtonItem = cancelButton;

  self.authenticationWebView = [[UIWebView alloc] init];
  self.authenticationWebView.delegate = self;
  self.authenticationWebView.scalesPageToFit = YES;
  [self.view addSubview:self.authenticationWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *linkedIn = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@", self.application.clientId, self.application.grantedAccessString, self.application.state, [self.application.redirectURL LIAEncode]];
    [self.authenticationWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkedIn]]];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.authenticationWebView.frame = self.view.bounds;
}


#pragma mark UI Action Methods

- (void)tappedCancelButton:(id)sender {
  self.cancelCallback();
}

@end

@implementation LIALinkedInAuthorizationViewController (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];

    //prevent loading URL if it is the redirectURL
    handlingRedirectURL = [url hasPrefix:self.application.redirectURL];

    if (handlingRedirectURL) {
        if ([url rangeOfString:@"error"].location != NSNotFound) {
            BOOL accessDenied = [url rangeOfString:kLinkedInDeniedByUser].location != NSNotFound;
            if (accessDenied) {
                self.cancelCallback();
            } else {
                NSError *error = [[NSError alloc] initWithDomain:kLinkedInErrorDomain code:1 userInfo:[[NSMutableDictionary alloc] init]];
                self.failureCallback(error);
            }
        } else {
            NSString *receivedState = [self extractGetParameter:@"state" fromURLString: url];
            //assert that the state is as we expected it to be
            if ([self.application.state isEqualToString:receivedState]) {
                //extract the code from the url
                NSString *authorizationCode = [self extractGetParameter:@"code" fromURLString: url];
                self.successCallback(authorizationCode);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:kLinkedInErrorDomain code:2 userInfo:[[NSMutableDictionary alloc] init]];
                self.failureCallback(error);
            }
        }
    }
    return !handlingRedirectURL;
}

- (NSString *)extractGetParameter: (NSString *) parameterName fromURLString:(NSString *)urlString {
    NSMutableDictionary *mdQueryStrings = [[NSMutableDictionary alloc] init];
    urlString = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
    for (NSString *qs in [urlString componentsSeparatedByString:@"&"]) {
        [mdQueryStrings setValue:[[[[qs componentsSeparatedByString:@"="] objectAtIndex:1]
                stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                          forKey:[[qs componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    return [mdQueryStrings objectForKey:parameterName];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!handlingRedirectURL)
        self.failureCallback(error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	
	/*fix for the LinkedIn Auth window - it doesn't scale right when placed into
	 a webview inside of a form sheet modal. If we transform the HTML of the page
	 a bit, and fix the viewport to 540px (the width of the form sheet), the problem
	 is solved.
	*/
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		NSString* js =
		@"var meta = document.createElement('meta'); "
		@"meta.setAttribute( 'name', 'viewport' ); "
		@"meta.setAttribute( 'content', 'width = 540px, initial-scale = 1.0, user-scalable = yes' ); "
		@"document.getElementsByTagName('head')[0].appendChild(meta)";
		
		[webView stringByEvaluatingJavaScriptFromString: js];
	}
}

@end