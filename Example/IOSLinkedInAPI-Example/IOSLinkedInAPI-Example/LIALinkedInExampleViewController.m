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
#import "LIALinkedInExampleViewController.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInClientExampleCredentials.h"


@implementation LIALinkedInExampleViewController {
  UIButton *_requestLinkedInTokenButton;
  LIALinkedInHttpClient *_client;

}

- (void)viewDidLoad {
  [super viewDidLoad];
  _client = [self client];
  self.view.backgroundColor = [UIColor whiteColor];
  _requestLinkedInTokenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_requestLinkedInTokenButton setTitle:@"Request token" forState:UIControlStateNormal];
  _requestLinkedInTokenButton.frame = CGRectMake(0, 0, 200, 44);
  _requestLinkedInTokenButton.center = self.view.center;
  [self.view addSubview:_requestLinkedInTokenButton];
  [_requestLinkedInTokenButton addTarget:self action:@selector(didRequestAuthToken) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  _requestLinkedInTokenButton.center = self.view.center;
}


- (void)didRequestAuthToken {

//  if ([_client validToken]) {
//    [self requestMeWithToken:[_client accessToken]];
//  } else {
    [_client getAuthorizationCode:^(NSString *code) {
      [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
        NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
        [self requestMeWithToken:accessToken];
      }                   failure:^(NSError *error) {
        NSLog(@"Quering accessToken failed %@", error);
      }];
    }                      cancel:^{
      NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
      NSLog(@"Authorization failed %@", error);
    }];
//  }
}

- (void)requestMeWithToken:(NSString *)accessToken {
  [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
    NSLog(@"current user %@", result);
  }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"failed to fetch current user %@", error);
  }];
}

- (LIALinkedInHttpClient *)client {
  LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                  clientId:LINKEDIN_CLIENT_ID
                                                                              clientSecret:LINKEDIN_CLIENT_SECRET
                                                                                     state:@"DCEEFWF45453sdffef424"
                                                                             grantedAccess:@[@"r_fullprofile", @"r_network"]];
  return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}


@end