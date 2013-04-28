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

NSString *kLinkedInErrorDomain = @"LIALinkedInERROR";
NSString *kLinkedInDeniedByUser = @"the+user+denied+your+request";

static NSString *const LINKEDIN_CODE_URL_SUFFIX = @"&state=%@";

static NSString *const LINKEDIN_CODE_URL_PREFIX = @"%@/?code=";


@interface LIALinkedInAuthorizationViewController ()
@property(nonatomic, strong) UIWebView *authenticationWebView;
@property(nonatomic, copy) LIAAuthorizationCodeFailureCallback failureCallback;
@property(nonatomic, copy) LIAAuthorizationCodeSuccessCallback successCallback;
@property(nonatomic, copy) LIAAuthorizationCodeCancelCallback cancelCallback;
@property(nonatomic, strong) LIALinkedInApplication *application;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
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
    self.view.backgroundColor = [UIColor whiteColor];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.activityIndicatorView startAnimating];
    [self.view addSubview:self.activityIndicatorView];

    self.authenticationWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.authenticationWebView.delegate = self;
    self.authenticationWebView.hidden = YES;
    [self.view addSubview:self.authenticationWebView];

    self.navigationController.navigationBarHidden = YES;

    NSString *linkedIn = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@", self.application.clientId, self.application.grantedAccessString, self.application.state, self.application.redirectURL];
    [self.authenticationWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkedIn]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation LIALinkedInAuthorizationViewController (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    if ([url hasPrefix:self.application.redirectURL]) {
        if ([url rangeOfString:@"error"].location != NSNotFound) {
            BOOL accessDenied = [url rangeOfString:kLinkedInDeniedByUser].location != NSNotFound;
            if (accessDenied) {
                self.cancelCallback();
            } else {
                NSError *error = [[NSError alloc] initWithDomain:kLinkedInErrorDomain code:1 userInfo:[[NSMutableDictionary alloc] init]];
                self.failureCallback(error);
            }
        } else {
            NSString *successPrefix = [NSString stringWithFormat:LINKEDIN_CODE_URL_PREFIX, self.application.redirectURL];
            NSString *successSuffix = [NSString stringWithFormat:LINKEDIN_CODE_URL_SUFFIX, self.application.state];

            //assert that the state is as we expected it to be
            if ([url hasSuffix:successSuffix]) {
                //extract the code from the url
                NSString *authorizationCode = [url substringWithRange:NSMakeRange([successPrefix length], [url length] - [successPrefix length] - [successSuffix length])];
                self.successCallback(authorizationCode);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:kLinkedInErrorDomain code:2 userInfo:[[NSMutableDictionary alloc] init]];
                self.failureCallback(error);
            }
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicatorView stopAnimating];
    self.authenticationWebView.hidden = NO;
}

@end