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

NSInteger kLinkedInAuthenticationCancelledByUser = 1;
NSInteger kLinkedInAuthenticationFailed = 2;
NSString *kLinkedInErrorDomain = @"LIALinkedInERROR";
NSString *kLinkedInDeniedByUser = @"the+user+denied+your+request";

@interface LIALinkedInAuthorizationViewController ()
@property(nonatomic, strong) UIWebView *authenticationWebView;
@property(nonatomic, copy) LIAAuthorizationCodeFailureCallback failureCallback;
@property(nonatomic, copy) LIAAuthorizationCodeSuccessCallback successCallback;
@property(nonatomic, strong) LIALinkedInApplication *application;
@end

@interface LIALinkedInAuthorizationViewController (UIWebViewDelegate) <UIWebViewDelegate>

@end

//todo: handle no network
@implementation LIALinkedInAuthorizationViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithApplication:(LIALinkedInApplication *)application andSuccess:(LIAAuthorizationCodeSuccessCallback)success andFailure:(LIAAuthorizationCodeFailureCallback)failure {
    self = [super init];
    if (self) {
        self.application = application;
        self.successCallback = success;
        self.failureCallback = failure;
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.authenticationWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.authenticationWebView.delegate = self;
    [self.view addSubview:self.authenticationWebView];

    //todo: assumes a navigation controller exists which isn't always true
    self.navigationController.navigationBarHidden = YES;

    NSString *linkedIn = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=foobar&redirect_uri=%@", self.application.clientId, self.application.grantedAccessString, self.application.redirectURL];
    [self.authenticationWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkedIn]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation LIALinkedInAuthorizationViewController (UIWebViewDelegate)
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"About to load request: %@", [[request URL] absoluteString]);
    NSString *url = [[request URL] absoluteString];
    if ([url hasPrefix:self.application.redirectURL]) {
        if ([url rangeOfString:@"error"].location != NSNotFound) {
            BOOL accessDenied = [url rangeOfString:kLinkedInDeniedByUser].location != NSNotFound;
            NSInteger errorCode = accessDenied ? kLinkedInAuthenticationCancelledByUser : kLinkedInAuthenticationFailed;
            NSError *error = [[NSError alloc] initWithDomain:kLinkedInErrorDomain code:errorCode userInfo:[[NSMutableDictionary alloc] init]];
            self.failureCallback(error);
        } else {
            NSLog(@"extracting the code from the URL %@", url);
            //extract the code from the url
            NSString *successPrefix = [NSString stringWithFormat:LINKEDIN_CODE_URL_PREFIX, self.application.redirectURL];
            NSString *successSuffix = [NSString stringWithFormat:LINKEDIN_CODE_URL_SUFFIX, self.application.state];
            NSString *authorizationCode = [url substringWithRange:NSMakeRange([successPrefix length], [url length] - [successPrefix length] - [successSuffix length])];
            self.successCallback(authorizationCode);
        }
        return NO;
    }
    return YES;
}

@end